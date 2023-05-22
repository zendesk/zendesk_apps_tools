# frozen_string_literal: true

require 'zendesk_apps_tools/theming/common'

module ZendeskAppsTools
  class Theme < Thor
    include Thor::Actions
    include ZendeskAppsTools::CommandHelpers
    include ZendeskAppsTools::Theming::Common

    desc 'preview', 'Preview a theme in development'
    shared_options(except: %i[clean unattended])
    method_option :port, default: Command::DEFAULT_SERVER_PORT, required: false, desc: 'Port for the http server to use.'
    method_option :bind, default: Command::DEFAULT_SERVER_IP, required: false
    method_option :livereload, type: :boolean, default: true, desc: 'Enable or disable live-reloading the preview when a change is made.'
    method_option :force_polling, type: :boolean, default: false, desc: 'Force the use of the polling adapter.'
    def preview
      setup_path(options[:path])
      ensure_manifest!
      require 'faraday'
      full_upload
      callbacks_after_upload = []
      start_listener(callbacks_after_upload)
      start_server(callbacks_after_upload)
    end

    no_commands do
      def full_upload
        say_status 'Generating', 'Generating theme from local files'
        payload = generate_payload
        say_status 'Generating', 'OK'
        say_status 'Uploading', 'Uploading theme'
        connection = get_connection(nil)
        connection.use Faraday::Response::RaiseError
        connection.put do |req|
          req.url '/hc/api/internal/theming/local_preview'
          req.body = JSON.dump(payload)
          req.headers['Content-Type'] = 'application/json'
        end
        say_status 'Uploading', 'OK'
        say_status 'Ready', "#{connection.url_prefix}hc/admin/local_preview/start"
        say "You can exit preview mode in the UI or by visiting #{connection.url_prefix}hc/admin/local_preview/stop"
      rescue Faraday::Error::ClientError => e
        say_status 'Uploading', "Failed: #{e.message}", :red
        begin
          error_hash = JSON.parse(e.response[:body])
          broken_templates = error_hash['template_errors']
          if broken_templates
            broken_templates.each do |template_name, errors|
              errors.each do |error|
                say_status 'Error', "#{template_name} L#{error['line']}:#{error['column']}: #{error['description']}", :red
              end
            end
          else
            say_status 'Error', error_hash
          end
        rescue JSON::ParserError
          say_error_and_exit 'Server error.'
        end
      end

      def start_listener(callbacks_after_upload)
        # TODO: do we need to stop the listener at some point?
        require 'listen'
        path = Pathname.new(theme_package_path('.')).cleanpath
        listener = ::Listen.to(path, ignore: /\.zat/, force_polling: options[:force_polling]) do |modified, added, removed|
          need_upload = false
          if modified.any? { |file| file[/templates|manifest/] }
            need_upload = true
          end
          if added.any? || removed.any?
            need_upload = true
          end
          if need_upload
            full_upload
          end
          callbacks_after_upload.each do |callback|
            callback.call
          end
        end
        listener.start
      end

      IDENTIFIER_REGEX = /.*templates\/(?<identifier>.*)(?=\.hbs)/

      def generate_payload
        payload = {}
        templates = Dir.glob(theme_package_path('templates/*.hbs')) + Dir.glob(theme_package_path('templates/*/*.hbs'))
        templates_payload = {}
        templates.each do |template|
          identifier = template.match(IDENTIFIER_REGEX)['identifier'].to_s
          templates_payload[identifier] = File.read(template)
        end
        script_location = 'document_head'
        style_location = 'document_head'
        livereload_location = 'document_head'

        #theming_v2 based theme should have script.js
        # injected at the end of the page
        if metadata_hash['api_version'] == 2
          script_location = 'footer'
        end

        payload['templates'] = templates_payload
        #inject tag in either document_head (theming_v1 based themes), or footer (theming_v2 based themes)
        payload['templates'][script_location] = inject_external_tags(payload['templates'][script_location],
                                                                     js_tag_hash['html'])
        payload['templates'][style_location] = inject_external_tags(payload['templates'][style_location],
                                                                    css_tag_hash['html'], true)
        payload['templates'][livereload_location] = inject_external_tags(payload['templates'][livereload_location],
                                                                         live_reload_script_tag_hash['html'])
        payload['templates']['css'] = ''
        payload['templates']['js'] = ''
        payload['templates']['assets'] = assets(base_url)
        payload['templates']['variables'] = settings_hash(base_url)
        payload['templates']['metadata'] = metadata_hash
        payload
      end

      def base_url
        "http://localhost:#{options[:port]}"
      end

      def live_reload_script_tag_hash
        { 'html' => <<-html
          <script type="text/javascript">
            RACK_LIVERELOAD_PORT = #{options[:port]};
          </script>
          <script src="#{base_url}/__rack/livereload.js?host=localhost"></script>
          html
        }
      end

      def js_tag_hash
        { 'html' => <<-html
          <script src="#{base_url}/guide/script.js"></script>
          html
        }
      end

      def css_tag_hash
        { 'html' => <<-html
          <link rel="stylesheet" type="text/css" href="#{base_url}/guide/style.css">
          html
        }
      end

      def inject_external_tags(template, tag_html, top=false)
        _template = StringIO.new
        _template << tag_html if top
        _template << template
        _template << tag_html unless top
        _template.string
      end

      alias_method :ensure_manifest!, :manifest

      def start_server(callbacks_after_upload)
        require 'zendesk_apps_tools/theming/server'
        if options[:livereload]
          require 'rack-livereload'
          require 'faye/websocket'
          Faye::WebSocket.load_adapter('thin')
        end

        ZendeskAppsTools::Theming::Server.tap do |server|
          server.set :bind, options[:bind] if options[:bind]
          server.set :port, options[:port]
          server.set :root, app_dir
          server.set :public_folder, app_dir
          server.set :livereload, options[:livereload]
          server.set :base_url, base_url
          server.set :callbacks_after_load, callbacks_after_upload
          server.set :callback_map, {}
          server.use Rack::LiveReload, live_reload_port: options[:port] if options[:livereload]
          server.run!
        end
      end
    end
  end
end

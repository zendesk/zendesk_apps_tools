require 'sinatra/base'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :protection, :except => :frame_options
    last_mtime = Time.new(0)
    ZENDESK_DOMAINS_REGEX = /^http(?:s)?:\/\/[a-z0-9-]+\.(?:zendesk|zopim|zd-(?:dev|master|staging))\.com$/

    get '/app.js' do
      access_control_allow_origin
      content_type 'text/javascript'

      if File.exists? settings.config
        curr_mtime = File.stat(settings.config).mtime
        if curr_mtime > last_mtime
          settings_helper = ZendeskAppsTools::Settings.new
          settings.parameters = settings_helper.get_settings_from_file(settings.config, settings.manifest)
          last_mtime = curr_mtime
        end
      end

      package = ZendeskAppsSupport::Package.new(settings.root, false)
      app_name = package.manifest_json['name'] || 'Local App'
      installation = ZendeskAppsSupport::Installation.new(
        id: settings.app_id,
        app_id: settings.app_id,
        app_name: app_name,
        enabled: true,
        requirements: package.requirements_json,
        settings: settings.parameters.merge({title: app_name}),
        updated_at: Time.now.iso8601,
        created_at: Time.now.iso8601
      )

      app_js = package.compile_js(
        app_id: settings.app_id,
        app_name: package.manifest_json['name'] || 'Local App',
        assets_dir: "http://localhost:#{settings.port}/",
        locale: params['locale']
      )

      ZendeskAppsSupport::Installed.new([app_js], [installation]).compile_js
    end

    get "/:file" do |file|
      access_control_allow_origin
      send_file File.join(settings.root, 'assets', file)
    end

    # This is for any preflight request
    options "*" do
      #don't delete this
      access_control_allow_origin
      headers 'Access-Control-Allow-Headers' => request.env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] if request.env['HTTP_ORIGIN'] =~ ZENDESK_DOMAINS_REGEX
    end

    def access_control_allow_origin
      origin = request.env['HTTP_ORIGIN']
      headers 'Access-Control-Allow-Origin' => origin if origin =~ ZENDESK_DOMAINS_REGEX
    end
  end
end

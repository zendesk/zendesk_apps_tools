require 'thor'
require 'pathname'
require 'json'

require 'zendesk_apps_tools/version'
require 'zendesk_apps_tools/command_helpers'

module ZendeskAppsTools
  class Command < Thor
    include Thor::Actions
    include ZendeskAppsTools::CommandHelpers

    map %w(-v) => :version

    source_root File.expand_path(File.join(File.dirname(__FILE__), '../..'))

    desc 'translate SUBCOMMAND', 'Manage translation files', hide: true
    subcommand 'translate', Translate

    desc 'bump SUBCOMMAND', 'Bump version for app', hide: true
    subcommand 'bump', Bump

    desc 'new', 'Generate a new app'
    method_option :'iframe-only', type: :boolean,
                                  default: false,
                                  hide: true,
                                  aliases: ['--v2']
    method_option :v1, type: :boolean,
                       default: false,
                       hide: true,
                       desc: 'Create a version 1 app template (Deprecated)'
    def new
      deprecated_message('error', '1.0') if options[:v1]

      enter = ->(variable) { "Enter this app author's #{variable}:\n" }
      invalid = ->(variable) { "Invalid #{variable}, try again:" }
      @author_name  = get_value_from_stdin(enter.call('name'),
                                           error_msg: invalid.call('name'))
      @author_email = get_value_from_stdin(enter.call('email'),
                                           valid_regex: /^.+@.+\..+$/,
                                           error_msg: invalid.call('email'))
      @author_url   = get_value_from_stdin(enter.call('url'),
                                           valid_regex: %r{^https?://.+$},
                                           error_msg: invalid.call('url'),
                                           allow_empty: true)
      @app_name     = get_value_from_stdin("Enter a name for this new app:\n",
                                           error_msg: invalid.call('app name'))

      @iframe_location = if options[:v1]
                           '_legacy'
                         else
                           iframe_uri_text = 'Enter your iFrame URI or leave it blank to use'\
                                             " a default local template page:\n"
                           get_value_from_stdin(iframe_uri_text, allow_empty: true, default: 'assets/iframe.html')
                         end

      prompt_new_app_dir

      directory_options = @iframe_location != 'assets/iframe.html' ? { exclude_pattern: /iframe.html/ } : {}
      directory('app_template_iframe', @app_dir, directory_options)
    end

    desc 'validate', 'Validate your app'
    shared_options(except: [:unattended])
    def validate
      require 'execjs'
      check_for_update
      setup_path(options[:path])
      begin
        errors = app_package.validate(marketplace: false)
      rescue ExecJS::RuntimeError
        error = "There was an error trying to validate this app.\n"
        if ExecJS.runtime.nil?
          error += 'Validation relies on a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.'
        elsif ExecJS.runtime.name == 'JScript'
          error += 'To validate on Windows, please install node from https://nodejs.org/'
        end
        say_error_and_exit error
      end
      valid = errors.none?

      if valid
        app_package.warnings.each { |w| say w.to_s, :yellow }
        deprecated_message
        say_status 'validate', 'OK'
      else
        errors.each do |e|
          say_status 'validate', e.to_s, :red
        end
      end

      @destination_stack.pop if options[:path]
      exit 1 unless valid
      true
    end

    desc 'package', 'Package your app'
    shared_options(except: [:unattended])
    def package
      return false unless validate

      setup_path(options[:path])

      say_status 'warning', 'Please note that the name key of manifest.json is currently only used in development.', :yellow if app_package.manifest.name

      archive_path = File.join(tmp_dir, "app-#{Time.now.strftime('%Y%m%d%H%M%S')}.zip")

      archive_rel_path = relative_to_original_destination_root(archive_path)

      zip archive_path

      say_status 'package', "created at #{archive_rel_path}"
      true
    end

    desc 'clean', 'Remove app packages in temp folder'
    method_option :path, default: './', required: false, aliases: '-p'
    def clean
      setup_path(options[:path])

      return unless File.exist?(Pathname.new(File.join(app_dir, 'tmp')).to_s)

      FileUtils.rm(Dir["#{tmp_dir}/app-*.zip"])
    end

    DEFAULT_SERVER_PATH = './'
    DEFAULT_CONFIG_PATH = './settings.yml'
    DEFAULT_SERVER_PORT = '4567'
    DEFAULT_APP_ID = 0

    desc 'server', 'Run a http server to serve the local app'
    shared_options(except: [:clean])
    method_option :config, default: DEFAULT_CONFIG_PATH, required: false, aliases: '-c'
    method_option :port, default: DEFAULT_SERVER_PORT, required: false
    method_option :app_id, default: DEFAULT_APP_ID, required: false, type: :numeric
    method_option :bind, required: false
    def server
      setup_path(options[:path])
      if app_package.has_file?('assets/app.js')
        say 'Warning: creating assets/app.js causes zat server to behave badly.', :yellow
      end

      require 'zendesk_apps_tools/server'
      ZendeskAppsTools::Server.tap do |server|
        server.set :settings_helper, settings_helper
        server.set :bind, options[:bind] if options[:bind]
        server.set :port, options[:port]
        server.set :root, options[:path]
        server.set :public_folder, File.join(options[:path], 'assets')
        server.set :parameters, settings
        server.set :app_id, options[:app_id]
        server.run!
      end
    end

    desc 'create', 'Create and install app on your account'
    shared_options
    method_option :zipfile, default: nil, required: false, type: :string
    method_option :config, default: DEFAULT_CONFIG_PATH, required: false, aliases: '-c'
    method_option :install, default: true, type: :boolean, desc: 'Also create an installation with some settings immediately after uploading.'
    def create
      cache.clear
      setup_path(options[:path])
      @command = 'Create'

      unless options[:zipfile]
        app_name = manifest.name
      end
      app_name ||= get_value_from_stdin('Enter app name:')
      deploy_app(:post, '/api/apps.json', name: app_name)
      has_requirements = File.exist?(File.join(options[:path], 'requirements.json'))
      return unless options[:install]
      product_names(manifest).each do |product_name|
        say_status 'Install', "installing in #{product_name}"
        install_app(has_requirements, product_name, app_id: cache.fetch('app_id'), settings: settings.merge(name: app_name))
      end
    end

    desc 'update', 'Update app on the server'
    shared_options
    method_option :zipfile, default: nil, required: false, type: :string
    def update
      cache.clear
      setup_path(options[:path])
      @command = 'Update'

      app_id = cache.fetch('app_id') || find_app_id
      unless /\d+/ =~ app_id.to_s
        say_error_and_exit "App id not found\nPlease try running command with --clean or check your internet connection"
      end
      deploy_app(:put, "/api/v2/apps/#{app_id}.json", {})
    end

    desc "version, -v", "Print the version"
    def version
      say ZendeskAppsTools::VERSION
    end

    protected

    def product_names(manifest)
      product_codes(manifest).collect{ |code| ZendeskAppsSupport::Product.find_by( code: code ) }.collect(&:name)
    end

    def product_codes(manifest)
      manifest.location_options.collect{ |option| option.location.product_code }
    end

    def setup_path(path)
      @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
    end

    def settings
      settings_helper.get_settings_from_file(options[:config], manifest.original_parameters) ||
        settings_helper.get_settings_from_user_input(manifest.original_parameters)
    end

    def settings_helper
      @settings_helper ||= begin
        require 'zendesk_apps_tools/settings'
        ZendeskAppsTools::Settings.new(self)
      end
    end

    def deprecated_message(type = 'warning', target_version = manifest.framework_version)
      require 'zendesk_apps_support/app_version'
      zas = ZendeskAppsSupport::AppVersion.new(target_version)

      version_status = zas.sunsetting? ? 'being sunset' : 'deprecated'
      deprecated_message = zas.sunsetting? ? "No new v#{target_version} app framework submissions will be accepted from August 1st, 2017" : "No new v#{target_version} app framework submissions or updates will be accepted"
      message = "You are targeting the v#{target_version} app framework, which is #{version_status}. #{deprecated_message}. Consider migrating to the v#{zas.current} framework. For more information: http://goto.zendesk.com/zaf-sunset"

      if zas.deprecated? || type == 'error'
        say_error_and_exit message
      elsif zas.sunsetting?
        say_status 'warning', message, :yellow
      end
    end

    def check_for_update
      begin
        require 'net/http'

        return unless (cache.fetch "zat_update_check").nil? || Date.parse(cache.fetch "zat_update_check") < Date.today - 7

        say_status 'info', 'Checking for new version of zendesk_apps_tools'
        response = Net::HTTP.get_response(URI('https://rubygems.org/api/v1/gems/zendesk_apps_tools.json'))

        latest_version = Gem::Version.new(JSON.parse(response.body)["version"])
        current_version = Gem::Version.new(ZendeskAppsTools::VERSION)

        cache.save 'zat_latest' => latest_version
        cache.save 'zat_update_check' => Date.today

        say_status 'warning', 'Your version of Zendesk Apps Tools is outdated. Update by running: gem update zendesk_apps_tools', :yellow if current_version < latest_version
      rescue SocketError
        say_status 'warning', 'Unable to check for new versions of zendesk_apps_tools gem', :yellow
      end
    end
  end
end

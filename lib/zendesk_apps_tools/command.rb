require 'thor'
require 'zip/zip'
require 'pathname'
require 'net/http'
require 'json'
require 'faraday'
require 'io/console'
require 'zendesk_apps_support'

require 'zendesk_apps_tools/version'
require 'zendesk_apps_tools/command_helpers'

module ZendeskAppsTools
  class Command < Thor
    include Thor::Actions
    include ZendeskAppsSupport
    include ZendeskAppsTools::CommandHelpers

    SHARED_OPTIONS = {
      ['path', '-p'] => './',
      clean: false
    }

    map %w[-v] => :version

    source_root File.expand_path(File.join(File.dirname(__FILE__), '../..'))

    desc 'translate SUBCOMMAND', 'Manage translation files', hide: true
    subcommand 'translate', Translate

    desc 'bump SUBCOMMAND', 'Bump version for app', hide: true
    subcommand 'bump', Bump

    desc 'new', 'Generate a new app'
    method_option :'iframe-only', type: :boolean,
                                  default: false,
                                  desc: 'Create an iFrame Only app template',
                                  aliases: ['-i', '--v2']
    def new
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

      @iframe_location = if options[:'iframe-only']
                           iframe_uri_text = 'Enter your iFrame URI or leave it blank to use'\
                                             " a default local template page:\n"
                           value = get_value_from_stdin(iframe_uri_text, allow_empty: true)
                           value == '' ? 'assets/iframe.html' : value
                         else
                           '_legacy'
                         end

      prompt_new_app_dir

      skeleton = options[:'iframe-only'] ? 'app_template_iframe' : 'app_template'
      is_custom_iframe = options[:'iframe-only'] && @iframe_location != 'assets/iframe.html'
      directory_options = is_custom_iframe ? { exclude_pattern: /iframe.html/ } : {}
      directory(skeleton, @app_dir, directory_options)
    end

    desc 'validate', 'Validate your app'
    method_options SHARED_OPTIONS
    def validate
      setup_path(options[:path])
      begin
        errors = app_package.validate(marketplace: false)
      rescue ExecJS::RuntimeError
        error = "There was an error trying to validate this app.\n"
        if ExecJS.runtime.name == 'JScript'
          error += 'To validate on Windows, please install node from https://nodejs.org/'
        end
        say_error_and_exit error
      end
      valid = errors.none?

      if valid
        app_package.warnings.each { |w| say w.to_s, :yellow }
        say_status 'validate', 'OK'
      else
        errors.each do |e|
          say_status 'validate', e.to_s
        end
      end

      @destination_stack.pop if options[:path]
      exit 1 unless valid
      true
    end

    desc 'package', 'Package your app'
    method_options SHARED_OPTIONS
    def package
      return false unless invoke(:validate, [])

      setup_path(options[:path])
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
    DEFAULT_SERVER_PORT = 4567
    DEFAULT_APP_ID = 0

    desc 'server', 'Run a http server to serve the local app'
    method_option :path, default: DEFAULT_SERVER_PATH, required: false, aliases: '-p'
    method_option :config, default: DEFAULT_CONFIG_PATH, required: false, aliases: '-c'
    method_option :port, default: DEFAULT_SERVER_PORT, required: false
    method_option :app_id, default: DEFAULT_APP_ID, required: false
    def server
      setup_path(options[:path])
      manifest = app_package.manifest

      settings_helper = ZendeskAppsTools::Settings.new(self)

      settings = settings_helper.get_settings_from_file options[:config], manifest.original_parameters

      unless settings
        settings = settings_helper.get_settings_from_user_input self, manifest.original_parameters
      end

      require 'zendesk_apps_tools/server'
      ZendeskAppsTools::Server.tap do |server|
        server.set :settings_helper, settings_helper
        server.set :port, options[:port]
        server.set :root, options[:path]
        server.set :public_folder, File.join(options[:path], 'assets')
        server.set :parameters, settings
        server.set :app_id, options[:app_id]
        server.run!
      end
    end

    desc 'create', 'Create app on your account'
    method_options SHARED_OPTIONS
    method_option :zipfile, default: nil, required: false, type: :string
    def create
      clear_cache
      @command = 'Create'

      unless options[:zipfile]
        app_name = JSON.parse(File.read(File.join options[:path], 'manifest.json'))['name']
      end
      app_name ||= get_value_from_stdin('Enter app name:')
      deploy_app(:post, '/api/v2/apps.json',  name: app_name)
    end

    desc 'update', 'Update app on the server'
    method_options SHARED_OPTIONS
    method_option :zipfile, default: nil, required: false, type: :string
    def update
      clear_cache
      @command = 'Update'

      app_id = fetch_cache('app_id') || find_app_id
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

    def setup_path(path)
      @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
    end
  end
end

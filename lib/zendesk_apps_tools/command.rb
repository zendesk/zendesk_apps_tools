require "thor"
require 'zip/zip'
require 'pathname'
require 'net/http'
require 'json'
require 'faraday'
require 'io/console'

require 'zendesk_apps_tools/command_helpers'

module ZendeskAppsTools

  require 'zendesk_apps_support'

  class Command < Thor

    SHARED_OPTIONS = {
      ['path', '-p'] => './',
      :clean => false
    }

    include Thor::Actions
    include ZendeskAppsSupport
    include ZendeskAppsTools::CommandHelpers

    source_root File.expand_path(File.join(File.dirname(__FILE__), "../.."))

    desc 'translate SUBCOMMAND', 'Manage translation files', :hide => true
    subcommand 'translate', Translate

    desc "new", "Generate a new app"
    def new
      @author_name  = get_value_from_stdin("Enter this app author's name:\n", :error_msg => "Invalid name, try again:")
      @author_email = get_value_from_stdin("Enter this app author's email:\n", :valid_regex => /^.+@.+\..+$/, :error_msg => "Invalid email, try again:")
      @author_url   = get_value_from_stdin("Enter this app author's url:\n", :valid_regex => /^https?:\/\/.+$/, :error_msg => "Invalid url, try again:", :allow_empty => true)
      @app_name     = get_value_from_stdin("Enter a name for this new app:\n", :error_msg => "Invalid app name, try again:")

      get_new_app_directory

      directory('app_template', @app_dir)
    end

    desc "validate", "Validate your app"
    method_options SHARED_OPTIONS
    def validate
      setup_path(options[:path])
      errors = app_package.validate
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

    desc "package", "Package your app"
    method_options SHARED_OPTIONS
    def package
      return false unless invoke(:validate, [])

      setup_path(options[:path])
      archive_path = File.join(tmp_dir, "app-#{Time.now.strftime('%Y%m%d%H%M%S')}.zip")

      archive_rel_path = relative_to_original_destination_root(archive_path)

      zip archive_path

      say_status "package", "created at #{archive_rel_path}"
      true
    end

    desc "clean", "Remove app packages in temp folder"
    method_option :path, :default => './', :required => false, :aliases => "-p"
    def clean
      setup_path(options[:path])

      return unless File.exists?(Pathname.new(File.join(app_dir, "tmp")).to_s)

      FileUtils.rm(Dir["#{tmp_dir}/app-*.zip"])
    end

    DEFAULT_SERVER_PATH = "./"
    DEFAULT_CONFIG_PATH = "./settings.yml"
    DEFAULT_SERVER_PORT = 4567

    desc "server", "Run a http server to serve the local app"
    method_option :path, :default => DEFAULT_SERVER_PATH, :required => false, :aliases => "-p"
    method_option :config, :default => DEFAULT_CONFIG_PATH, :required => false, :aliases => "-c"
    method_option :port, :default => DEFAULT_SERVER_PORT, :required => false
    def server
      setup_path(options[:path])
      manifest = app_package.manifest_json

      settings_helper = ZendeskAppsTools::Settings.new

      settings = settings_helper.get_settings_yaml(File.join(options[:config]), manifest[:parameters])
      unless settings
        settings = settings_helper.get_settings_from(self, manifest[:parameters])
      end

      require 'zendesk_apps_tools/server'
      ZendeskAppsTools::Server.tap do |server|
        server.set :port, options[:port]
        server.set :root, options[:path]
        server.set :parameters, settings
        server.run!
      end
    end

    desc "create", "Create app on your account"
    method_options SHARED_OPTIONS
    method_option :zipfile, :default => nil, :required => false, :type => :string
    def create
      clear_cache
      @command = 'Create'

      unless options[:zipfile]
        app_name = JSON.parse(File.read(File.join options[:path], 'manifest.json'))['name']
      end
      app_name ||= get_value_from_stdin('Enter app name:')
      deploy_app(:post, '/api/v2/apps.json', { :name => app_name })
    end

    desc "update", "Update app on the server"
    method_options SHARED_OPTIONS
    method_option :zipfile, :default => nil, :required => false, :type => :string
    def update
      clear_cache
      @command = 'Update'

      app_id = get_cache('app_id') || find_app_id
      unless /\d+/ =~ app_id.to_s
        say_error_and_exit "App id not found\nPlease try running command with --clean or check your internet connection"
      end
      deploy_app(:put, "/api/v2/apps/#{app_id}.json", {})
    end

    protected

    def setup_path(path)
      @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
    end

  end
end

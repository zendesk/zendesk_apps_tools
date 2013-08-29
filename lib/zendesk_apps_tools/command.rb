require "thor"
require 'zip/zip'
require 'pathname'
require 'net/http'
require 'json'
require 'zendesk_apps_tools/translate'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/settings'

module ZendeskAppsTools
  require 'zendesk_apps_support'

  class Command < Thor

    DEFAULT_ZENDESK_URL = "http://support.zendesk.com"

    include Thor::Actions
    include ZendeskAppsSupport
    include ZendeskAppsTools::Common

    source_root File.expand_path(File.join(File.dirname(__FILE__), "../.."))

    desc 'translate SUBCOMMAND', 'Manage translation files', :hide => true
    subcommand 'translate', Translate

    desc "new", "Generate a new app"
    def new
      @author_name = get_value_from_stdin("Enter this app author's name:\n", :error_msg => "Invalid name, try again:")
      @author_email = get_value_from_stdin("Enter this app author's email:\n", :valid_regex => /^.+@.+\..+$/, :error_msg => "Invalid email, try again:")
      @app_name = get_value_from_stdin("Enter a name for this new app:\n", :error_msg => "Invalid app name, try again:")

      prompt = "Enter a directory name to save the new app (will create the dir if it does not exist, default to current dir):\n"
      while @app_dir = get_value_from_stdin(prompt) do
        @app_dir = './' and break if @app_dir.empty?
        if !File.exists?(@app_dir)
          break
        elsif !File.directory?(@app_dir)
          puts "Invalid dir, try again:"
        else
          break
        end
      end

      directory('app_template', @app_dir)
    end

    desc "validate", "Validate your app"
    method_option :path, :default => './', :required => false
    def validate
      prompt = "Enter a zendesk URL that you'd like to install the app (for example: 'http://abc.zendesk.com', default to '#{DEFAULT_ZENDESK_URL}'):\n"
      zendesk = get_value_from_stdin(prompt, :valid_regex => /^http:\/\/\w+\.\w+|^$/, :error_msg => 'Invalid url, try again:')
      zendesk = DEFAULT_ZENDESK_URL if zendesk.empty?
      url = URI.parse(zendesk)
      response = Net::HTTP.start(url.host, url.port) { |http| http.get('/api/v2/apps/framework_versions.json') }
      version = JSON.parse(response.body, :symbolize_names => true)
      if ZendeskAppsSupport::AppVersion::CURRENT != version[:current]
        puts 'This tool is using an out of date Zendesk App Framework. Please upgrade!'
        exit 1
      end

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
    method_option :path, :default => './', :required => false
    def package
      setup_path(options[:path])
      archive_path = File.join(tmp_dir, "app-#{Time.now.strftime('%Y%m%d%H%M%S')}.zip")

      return false unless invoke(:validate, [])

      archive_rel_path = relative_to_original_destination_root(archive_path)

      Zip::ZipFile.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          say_status "package", "adding #{file.relative_path}"
          zipfile.add(file.relative_path, app_dir.join(file.relative_path).to_s)
        end
      end

      say_status "package", "created at #{archive_rel_path}"
      true
    end

    desc "clean", "Remove app packages in temp folder"
    method_option :path, :default => './', :required => false
    def clean
      setup_path(options[:path])

      return unless File.exists?(Pathname.new(File.join(app_dir, "tmp")).to_s)

      FileUtils.rm(Dir["#{tmp_dir}/app-*.zip"])
    end

    DEFAULT_SERVER_PATH = "./"
    DEFAULT_SERVER_PORT = 4567

    desc "server", "Run a http server to serve the local app"
    method_option :path, :default => DEFAULT_SERVER_PATH, :required => false
    method_option :port, :default => DEFAULT_SERVER_PORT, :required => false
    def server
      setup_path(options[:path])
      manifest = app_package.manifest_json

      settings_helper = ZendeskAppsTools::Settings.new self
      settings = settings_helper.settings_for_parameters(manifest[:parameters])

      require 'zendesk_apps_tools/server'
      ZendeskAppsTools::Server.tap do |server|
        server.set :port, options[:port]
        server.set :root, options[:path]
        server.set :parameters, settings
        server.run!
      end
    end

    protected

    def setup_path(path)
      @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
    end

    def app_dir
      @app_dir ||= Pathname.new(destination_root)
    end

    def tmp_dir
      @tmp_dir ||= Pathname.new(File.join(app_dir, "tmp")).tap do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def app_package
      @app_package ||= Package.new(self.app_dir.to_s)
    end

  end
end


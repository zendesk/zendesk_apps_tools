require "thor"
require 'zip/zip'
require 'pathname'
require 'net/http'
require 'json'
require 'faraday'
require 'io/console'

require 'zendesk_apps_tools/translate'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/settings'

module ZendeskAppsTools
  require 'zendesk_apps_support'

  class Command < Thor

    DEFAULT_ZENDESK_URL = 'http://support.zendesk.com'
    URL_TEMPLATE        = 'https://%s.zendesk.com/'
    CACHE_FILE_NAME     = '.zat'
    GENERAL_ERROR_MSG   = 'Something went wrong, please try again!'
    SHARED_OPTIONS      = {
      :path =>  './',
      :clean => false
    }

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
      opts = { :valid_regex => /^(\w|\/|\\)*$/, :allow_empty => true }
      while @app_dir = get_value_from_stdin(prompt, opts) do
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
    method_options SHARED_OPTIONS
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
    method_options SHARED_OPTIONS
    def package
      setup_path(options[:path])
      archive_path = File.join(tmp_dir, "app-#{Time.now.strftime('%Y%m%d%H%M%S')}.zip")

      return false unless invoke(:validate, [])

      archive_rel_path = relative_to_original_destination_root(archive_path)

      Zip::ZipFile.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          path = file.relative_path
          say_status "package", "adding #{path}"

          # resolve symlink to source path
          if File.symlink? file.absolute_path
            path = File.readlink(file.absolute_path)
          end
          zipfile.add(file.relative_path, app_dir.join(path).to_s)
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

      settings_helper = ZendeskAppsTools::Settings.new
      settings = settings_helper.get_settings_from(self, manifest[:parameters])

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
      prepare_api_auth
      upload_id = upload options[:path]

      connection = get_connection

      response = connection.post do |req|
        req.url '/api/v2/apps.json'
        req.headers['Content-Type'] = 'application/json'

        app_name = get_value_from_stdin('Enter app name:')
        req.body = JSON.generate({
          :name => app_name,
          :upload_id => "#{upload_id}"
        })
      end

      status, message, app_id = check_status response
      if status == 'completed'
        set_cache 'app_id' => app_id
        say_status 'Create', 'OK'
      else
        say_status 'Create', message
      end
    rescue
      say GENERAL_ERROR_MSG, :red
    end

    desc "update", "Update app on the server"
    method_options SHARED_OPTIONS
    method_option :zipfile, :default => nil, :required => false, :type => :string
    def update
      prepare_api_auth
      upload_id = upload options[:path]

      app_id = get_cache('app_id') || find_app_id

      connection = get_connection

      response = connection.put do |req|
        req.url "/api/v2/apps/#{app_id}.json"
        req.headers['Content-Type'] = 'application/json'

        req.body = JSON.generate upload_id: "#{upload_id}"
      end

      status, message, _ = check_status response
      if status == 'completed'
        say_status 'Update', 'OK'
      else
        say_status 'Update', message
      end
    rescue
      say GENERAL_ERROR_MSG, :red
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

    def set_cache(hash)
      @cache = File.exists?(cache_path) ? JSON.parse(File.read(@cache_path)).update(hash) : hash
      File.open(@cache_path, 'w') { |f| f.write JSON.pretty_generate(@cache) }
    end

    def get_cache(key)
      @cache ||= File.exists?(cache_path) ? JSON.parse(File.read(@cache_path)) : {}
      @cache[key] if @cache
    end

    def clear_cache
      File.delete cache_path if File.exists? cache_path
    end

    def cache_path
      @cache_path ||= File.join options[:path], CACHE_FILE_NAME
    end

    def find_app_id
      say_status 'Update', 'app ID is missing, searching...'
      name = get_value_from_stdin('Enter the name of the app:')

      connection = get_connection

      all_apps = connection.get('/api/v2/apps.json').body

      app = JSON.parse(all_apps)['apps'].find { |app| app['name'] == name }

      set_cache 'app_id' => app['id']
      app['id']
    end

    def prepare_api_auth
      clear_cache if options[:clean]

      @subdomain = get_cache('subdomain') || get_value_from_stdin('Enter your subdomain:')
      @username  = get_cache('username') || get_value_from_stdin('Enter your username:')
      print 'Enter your password: '
      @password  = STDIN.noecho(&:gets).chomp
      puts

      set_cache 'subdomain' => @subdomain, 'username' => @username
    end

    def get_connection(multipart = nil)
      Faraday.new (URL_TEMPLATE % @subdomain) do |f|
        f.request :multipart if multipart == :multipart
        f.request :url_encoded
        f.adapter :net_http
        f.basic_auth @username, @password
      end
    end

    def upload(path)
      connection = get_connection :multipart

      unless options[:zipfile]
        package
        package_path = Dir[File.join path, '/tmp/*.zip'].sort.last
      else
        package_path = options[:zipfile]
      end

      payload = { :uploaded_data => Faraday::UploadIO.new(package_path, 'application/zip') }

      response = connection.post('/api/v2/apps/uploads.json', payload)
      JSON.parse(response.body)['id']
    rescue
      say 'Something went wrong while uploading', :red
      exit 1
    end

    def check_status(response)
      job = response.body
      job_id = JSON.parse(job)['job_id']

      check_job job_id
    end

    def check_job(job_id)
      connection = get_connection

      loop do
        response = connection.get("/api/v2/apps/job_statuses/#{job_id}")
        info     = JSON.parse(response.body)
        status   = info['status']
        message  = info['message']
        app_id   = info['app_id']

        return status, message, app_id if ['completed', 'failed'].include? status

        say_status 'Status', status
        sleep 3
      end
    end

  end
end


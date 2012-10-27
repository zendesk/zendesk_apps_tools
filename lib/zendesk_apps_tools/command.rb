require "thor"
require 'zip/zip'
require 'pathname'

module ZendeskAppsTools
  class Command < Thor
    class_option :config_file, :type => :string, :default => "Zamfile"

    include Thor::Actions
    source_root File.expand_path(File.join(File.dirname(__FILE__), "../.."))

    attr_accessor :author, :app_name, :app_package

    desc "auth", "Try to authenticate with Zendesk App Market"
    def auth
      resp = self.connection.auth
      if resp.status == 200
        say_status "auth", "OK"
      else
        say_status "error", "#{resp.status}: #{resp.body}"
      end
    end

    desc "list", "List all your apps"
    def list
      return unless invoke(:auth)
      resp = self.connection.list_apps
      if resp.status != 200
        say_status "error", "#{resp.status}: #{resp.body}"
      else
        JSON.parse(resp.body).each do |app|
          say_status "app", "name: #{app['name']}, created: #{app['created_at']}"
        end
      end
    end

    desc "new APP_NAME", "Generate a new app"
    def new(app_name)
      @app_name = app_name
      @author = zam_file.author
      directory('template', app_name)
    end

    desc "validate", "Validate your app"
    def validate(path_to_app = nil)
      @destination_stack << relative_to_original_destination_root(path_to_app) if path_to_app
      errors = app_package.validate
      valid = errors.none?

      if valid
        say_status 'validate', 'OK'
      else
        errors.each do |e|
          say_status 'validate', e.to_s
        end
      end

      @destination_stack.pop if path_to_app
      exit 1 unless valid
      true
    end

    desc "package", "Package your app"
    def package
      archive_path = File.join(tmp_dir, "app.zip")

      if !stale?
        say_status "package", "Nothing changed"
        return true
      end

      return false unless invoke(:validate, [])

      archive_rel_path = relative_to_original_destination_root(archive_path)
      remove_file(archive_path)

      Zip::ZipFile.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          say_status "package",  "adding #{file.relative_path}"
          zipfile.add(file.relative_path, file.relative_path)
        end
      end

      say_status "package", "created at #{archive_rel_path}"
      true
    end

    desc "check", "Check for changes"
    def check
      if stale?
        say_status "check", "Changed"
      else
        say_status "check", "No change"
      end
    end

    desc "push APP_NAME", "Push a new version of your app"
    def push(app_name)
      return unless [:auth, :package].all? {|task| invoke(task)}
      zip_file_path = File.join(tmp_dir, "app.zip")
      resp = self.connection.upload_app(app_name, zip_file_path)
      if resp.status == 201
        say_status "push", "package uploaded"
        say_status "push", "processing"
        spin do
          check_job_status(JSON.parse(resp.body)["job_id"])
        end
      else
        say_status "error", "#{resp.status}: #{resp.body}"
      end
    end

    desc "clean", "Remove temporary files"
    def clean
      inside(self.tmp_dir) do
        FileUtils.rm(Dir.glob(".*") - [".", ".."])
      end
    end
    protected

    def spin
      i = 0
      loop do
        print "."
        if i % 4 == 0
          return if yield
        end
        sleep 0.2
        i = i + 1
      end
    end

    def check_job_status(job_id)
      resp = self.connection.job_status(job_id)
      if resp.status != 200
        puts
        say_status "error", resp.body
        return true
      end

      status = JSON.parse(resp.body)
      case status["status"]
      when "queued", "working"
        false
      when "completed"
        puts
        say_status "push", "OK"
        true
      when "failed", "killed"
        puts
        say_status "error", status["message"]
        true
      end
    end

    def zam_file
      @zam_file ||= ZamFile.new(options[:config_file])
    end

    def connection
      @connection ||= Connection.new(zam_file)
    end

    def app_dir
      @app_dir ||= Pathname.new(destination_root)
    end

    def tmp_dir
      @tmp_dir ||= Pathname.new(File.join(app_dir, "tmp")).tap do |dir|
        mkdir_p dir
      end
    end

    def stale?
      app_hash.stale?
    end

    def app_hash
      @app_hash ||= AppHash.new(app_package, tmp_dir)
    end

    def app_package
      @app_package ||= Package.new(self.app_dir)
    end

    def mkdir_p(path)
      FileUtils.mkdir_p(path)
    end
  end
end


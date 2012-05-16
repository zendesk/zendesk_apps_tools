require "thor"

module Zam
  class Command < Thor
    include Thor::Actions
    TEMPLATE_DIR = File.expand_path(File.join(File.dirname(__FILE__), "../../template"))

    def connection
      @connection ||= begin
        zam_file = Zam::ZamFile.new(".zam")
        Zam::Connection.build(zam_file)     
      end
    end

    desc "auth", "Try to authenticate with Zendesk App Market"
    def auth
      resp = self.connection.get('/users/current.json')
      if resp.status == 200
        puts "OK"
      else
        puts "#{resp.status}: #{resp.body}"
      end
    end

    desc "new", "Generate a new app"
    def new
      directory(TEMPLATE_DIR, File.expand_path("."))
    end
  end
end


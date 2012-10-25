module ZendeskAppsTools
  class ZamFile

    SETTERS = [
               :url,
               :subdomain,
               :email,
               :auth_token,
               :ca_file,
               :ca_path,
               :author
              ]
    class Dsl
      attr_reader :zam_file
      def initialize(zam_file)
        @zam_file = zam_file
      end

      SETTERS.each do |setter|
        define_method(setter) do |*args|
          zam_file.send("#{setter}=", *args)
        end
      end

    end

    attr_accessor *SETTERS

    def initialize(file)
      @zam_file = file
      @dsl = Dsl.new(self)
      @dsl.instance_eval(File.read(@zam_file), @zam_file)
    end

    def author=(name, email)
      @author = {
        "name" => name,
        "email" => email
      }
    end

    def url
      @url || "https://#{@subdomain}.zendesk.com"
    end
  end
end

require 'openssl'
require 'faraday'

module ZendeskAppsSupport
  class Connection

    class AuthMiddleware < Faraday::Middleware
      class << self
        attr_accessor :session_cookie
      end

      def call(env)
        if !self.class.session_cookie.nil?
          env[:request_headers]['Cookie'] = self.class.session_cookie
        end
        @app.call(env)
      end
    end

    def initialize(config)
      @config = config
    end

    def auth
      self.connection.get('/users/current.json').tap do |resp|
        if resp.status == 200
          Zam::Connection::AuthMiddleware.session_cookie = resp.headers['set-cookie']
        end
      end
    end

    def list_apps
      self.connection.get('/api/v2/apps/owned.json')
    end

    def upload_app(app_name, zip_file)
      upload = Faraday::UploadIO.new(zip_file, "application/zip")
      self.connection.post('/api/v2/apps/uploads.json', {
                             :name => app_name,
                             :uploaded_data => upload
                           })
    end

    def job_status(job_id)
      self.connection.get("/api/v2/apps/job_statuses/#{job_id}")
    end

    def connection
      @conn ||= begin
        Faraday.new(@config.url, :ssl => self.ssl_config(@config))  do |builder|
          builder.request :basic_auth, "#{@config.email}/token", @config.auth_token
          builder.request :multipart
          builder.use AuthMiddleware
          builder.adapter  :net_http
        end
      end
    end

    def ssl_config(config)
      if config.ca_file || config.ca_path
        {
          :ca_file => config.ca_file,
          :ca_path => config.ca_path
        }
      else
        {}
      end
    end
  end
end

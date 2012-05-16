require 'openssl'
module Zam
  module Connection
    extend self

    def build(config)
      Faraday::Connection.new(config.url, self.ssl_config(config)).tap do |conn|
        conn.basic_auth("#{config.email}/token", config.auth_token)
      end
    end

    def ssl_config(config)
      if config.ca_file || config.ca_path
        {
          :ssl => {
            :ca_file => config.ca_file,
            :ca_path => config.ca_path
          }
        }
      else
        {}
      end
    end
  end
end

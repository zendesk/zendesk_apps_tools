module ZendeskAppsTools
  module APIConnection
    FULL_URL     = /https?:\/\//
    URL_TEMPLATE = 'https://%s.zendesk.com/'

    def prepare_api_auth
      @subdomain ||= cache.fetch('subdomain') || get_value_from_stdin('Enter your Zendesk subdomain or full Zendesk URL:')
      @username  ||= cache.fetch('username', @subdomain) || get_value_from_stdin('Enter your username:')
      @password  ||= cache.fetch('password', @subdomain) || get_password_from_stdin('Enter your password:')

      cache.save 'subdomain' => @subdomain, 'username' => @username
    end

    def get_connection(encoding = :url_encoded)
      require 'net/http'
      require 'faraday'
      prepare_api_auth
      Faraday.new full_url do |f|
        f.request encoding if encoding
        f.adapter :net_http
        f.basic_auth @username, @password
      end
    end

    private

    def full_url
      if FULL_URL =~ @subdomain
        @subdomain
      else
        URL_TEMPLATE % @subdomain
      end
    end
  end
end

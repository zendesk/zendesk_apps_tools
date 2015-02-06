module ZendeskAppsTools
  module APIConnection
    FULL_URL     = /https?:\/\//
    URL_TEMPLATE = 'https://%s.zendesk.com/'

    def prepare_api_auth
      @subdomain ||= fetch_cache('subdomain') || get_value_from_stdin('Enter your Zendesk subdomain or full Zendesk URL:')
      @username  ||= fetch_cache('username') || get_value_from_stdin('Enter your username:')
      @password  ||= fetch_cache('password') || get_password_from_stdin('Enter your password:')

      save_cache 'subdomain' => @subdomain, 'username' => @username
    end

    def get_connection(encoding = :url_encoded)
      prepare_api_auth
      Faraday.new full_url do |f|
        f.request encoding
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

module ZendeskAppsTools
  module APIConnection
    DEFAULT_URL_TEMPLATE = 'https://%s.zendesk.com/'
    # taken from zendesk/lib/vars.rb
    SUBDOMAIN_VALIDATION_PATTERN = /^[a-z0-9][a-z0-9\-]{1,}[a-z0-9]$/i
    ZENDESK_URL_VALIDATION_PATTERN = /^(https?):\/\/[a-z0-9]+(([\.]|[\-]{1,2})[a-z0-9]+)*\.([a-z]{2,16}|[0-9]{1,3})((:[0-9]{1,5})?(\/?|\/.*))?$/ix
    EMAIL_REGEX  = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})(\/token)?$/i

    EMAIL_ERROR_MSG = 'Please enter a valid email address.'
    PROMPT_FOR_URL  = 'Enter your Zendesk subdomain or full URL (including protocol):'
    URL_ERROR_MSG   = [
      'URL error. Example URL: https://mysubdomain.zendesk.com',
      'If you are using a full URL, follow the example format shown above.',
      'If you are using a subdomain, ensure that it contains only valid characters (a-z, A-Z, 0-9, and hyphens).'
    ].join('\n')

    def prepare_api_auth
      @subdomain ||= ENV['ZAT_URL'] || cache.fetch('subdomain') || get_value_from_stdin(PROMPT_FOR_URL)
      say_error_and_exit URL_ERROR_MSG unless valid_subdomain? || valid_full_url?

      @username  ||= ENV['ZAT_USERNAME'] || cache.fetch('username', @subdomain) || get_value_from_stdin('Enter your username:')
      say_error_and_exit EMAIL_ERROR_MSG unless valid_email?

      @password  ||= ENV['ZAT_PASSWORD'] || cache.fetch('password', @subdomain) || get_password_from_stdin('Enter your password:')
    end

    def get_connection(encoding = :url_encoded)
      require 'net/http'
      require 'faraday'
      prepare_api_auth unless @subdomain && @username && @password

      Faraday.new full_url do |f|
        f.request encoding if encoding
        f.adapter :net_http
        f.basic_auth @username, @password
      end
    end

    private

    def full_url
      valid_full_url? ? @subdomain : (DEFAULT_URL_TEMPLATE % @subdomain)
    end

    def valid_full_url?
      !!ZENDESK_URL_VALIDATION_PATTERN.match(@subdomain)
    end

    def valid_subdomain?
      !!SUBDOMAIN_VALIDATION_PATTERN.match(@subdomain)
    end

    def valid_email?
      !!EMAIL_REGEX.match(@username)
    end
  end
end

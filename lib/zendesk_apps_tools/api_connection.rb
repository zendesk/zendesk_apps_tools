module ZendeskAppsTools
  module APIConnection
    DEFAULT_URL_TEMPLATE = 'https://%s.zendesk.com/'
    # taken from zendesk/lib/vars.rb
    SUBDOMAIN_VALIDATION_PATTERN = /^[a-z0-9][a-z0-9\-]{1,}[a-z0-9]$/i
    ZENDESK_URL_VALIDATION_PATTERN = /^(https?):\/\/[a-z0-9]+(([\.]|[\-]{1,2})[a-z0-9]+)*\.([a-z]{2,16}|[0-9]{1,3})((:[0-9]{1,5})?(\/?|\/.*))?$/ix
    EMAIL_REGEX  = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i

    EMAIL_ERROR_MSG = 'Please enter a valid email address.'
    PROMPT_FOR_URL  = 'Enter your Zendesk subdomain or full URL (including protocol):'
    URL_ERROR_MSG   = [
      'URL error. Example URL: https://mysubdomain.zendesk.com',
      'If you are using FULL url, please follow the url as shown above.',
      'If you are using URL subdomain, please enter the equivalent of \'mysubdomain\' of the url above.'
    ].join('\n')

    def prepare_api_auth
      @subdomain ||= cache.fetch('subdomain') || get_value_from_stdin(PROMPT_FOR_URL)
      say_error_and_exit URL_ERROR_MSG unless valid_subdomain? || valid_full_url?

      @username  ||= cache.fetch('username', @subdomain) || get_value_from_stdin('Enter your username:')
      say_error_and_exit EMAIL_ERROR_MSG unless valid_email?

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

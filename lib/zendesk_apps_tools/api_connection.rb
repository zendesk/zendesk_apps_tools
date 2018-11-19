module ZendeskAppsTools
  module APIConnection
    SUBDOMAIN    = /\A[a-z0-9][a-z0-9\-]{1,}[a-z0-9]\z/
    FULL_URL     = Regexp::new(/https?:\/\//.source + SUBDOMAIN.source + /\.zendesk\.com/.source)
    URL_TEMPLATE = 'https://%s.zendesk.com/'

    # For Ruby 2 and 2.1 compatible
    EMAIL_REGEX  = URI::MailTo.constants.include?(:EMAIL_REGEXP) ? URI::MailTo::EMAIL_REGEXP : URI::MailTo::MAILTO_REGEXP

    EMAIL_ERROR_MSG     = 'Please enter a valid email address'
    SUBDOMAIN_ERROR_MSG = 'Make sure you entered the right subdomain name '\
      '(e.g. if account url is https://mysubdomain.zendesk.com, then enter mysubdomain).'

    def prepare_api_auth
      @subdomain ||= cache.fetch('subdomain') || get_value_from_stdin('Enter your Zendesk subdomain:')
      say_error_and_exit SUBDOMAIN_ERROR_MSG unless @subdomain =~ SUBDOMAIN

      @username  ||= cache.fetch('username', @subdomain) || get_value_from_stdin('Enter your username:')
      say_error_and_exit EMAIL_ERROR_MSG unless @username =~ EMAIL_REGEX

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

require 'uri'
require 'multi_json'

module ZendeskAppsSupport
  ConfigurationError = Class.new(StandardError)

  class Config

    class MissingSetting < ConfigurationError
      def initialize(attribute)
        super("Missing required setting #{attribute}")
      end
    end

    BadSetting = Class.new(ConfigurationError)

    attr_reader :url, :email, :auth_token, :ca_file

    def initialize(file)
      load_config(file)
    end

    private

    def load_config(file)
      config = MultiJson.decode(File.read(file))

      @email      = parse_email(config)
      @auth_token = parse_auth_token(config)
      @ca_file    = parse_ca_file(config)
      @url        = parse_url(config)
      @author     = parse_author(config)
    end

    def parse_email(config)
      config['email'].tap do |email|
        raise MissingSetting.new('email') unless email
        validate_email_address!(email)
      end
    end

    def parse_auth_token(config)
      config['auth_token'].tap do |token|
        raise MissingSetting.new('auth_token') unless t
      end
    end

    def parse_ca_file(config)
      config['ca_file'].tap do |file|
        raise MissingSetting.new('ca_file') unless file
        raise BadSetting.new("No such file: #{file}") unless File.file?(file)
      end
    end

    def parse_url(config)
      url, subdomain = config['url'], config['subdomain']
      raise MissingSetting.new('subdomain') unless url || subdomain
      url ||= "https://#{subdomain}.zendesk.com"
      URI.parse(url).tap do |uri|
        raise BadSetting.new("#{uri} does not look like a URL") unless uri.kind_of?(URI::HTTP)
      end
    end

    def parse_author(config)
      config['author'].tap do |author|
        raise MissingSetting.new('author') unless author
        raise MissingSetting.new('author.name') unless name
        email = author['email']
        raise MissingSetting.new('author.email') unless email
        validate_email_address!(email)
      end
    end

    def validate_email_address!(email)
      raise BadSetting.new("#{email} does not look like an email address") unless email =~ /.+@.+\..+/
    end

  end
end

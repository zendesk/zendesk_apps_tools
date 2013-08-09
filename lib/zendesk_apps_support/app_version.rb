require 'multi_json'

module ZendeskAppsSupport

  # At any point in time, we support up to three versions:
  #  * deprecated -- we will still serve apps targeting the deprecated version,
  #                  but newly created or updated apps CANNOT target it
  #  * current    -- we will serve apps targeting the current version;
  #                  newly created or updated apps SHOULD target it
  #  * future     -- we will serve apps targeting the future version;
  #                  newly created or updates apps MAY target it, but it
  #                  may change without notice
  class AppVersion

    DEPRECATED = '0.4'.freeze
    CURRENT    = '0.5'.freeze
    FUTURE     = '1.0'.freeze

    TO_BE_SERVED     = [ DEPRECATED, CURRENT, FUTURE ].compact.freeze
    VALID_FOR_UPDATE = [ CURRENT, FUTURE ].compact.freeze

    def initialize(version)
      @version = version.to_s
      @version.freeze
      freeze
    end

    def servable?
      TO_BE_SERVED.include?(@version)
    end

    def valid_for_update?
      VALID_FOR_UPDATE.include?(@version)
    end

    def deprecated?
      @version == DEPRECATED
    end

    def obsolete?
      !servable?
    end

    def blank?
      @version.nil? || @version == ''
    end

    def present?
      !blank?
    end

    def to_s
      @version
    end

    def to_json(*options)
      MultiJson.encode(@version)
    end

    def ==(other)
      @version == other.to_s
    end

  end

  AppVersion.freeze

end

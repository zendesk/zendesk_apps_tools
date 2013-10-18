module ZendeskAppsTools
  class LocaleIdentifier
    attr_reader :language_id

    # Convert :"en-US-x-12" to 'en-US'
    def initialize(code)
      @language_id = code.sub(/-x-.*/, '')
    end
  end
end

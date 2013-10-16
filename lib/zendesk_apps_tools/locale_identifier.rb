module ZendeskAppsTools
  class LocaleIdentifier
    attr_reader :language_id

    # Convert :"en-US-x-12" to 'en'
    def initialize(code)
      @language_id = code.sub(/-x-.*/, '')
    end
  end
end

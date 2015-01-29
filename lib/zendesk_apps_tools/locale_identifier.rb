module ZendeskAppsTools
  class LocaleIdentifier
    attr_reader :locale_id

    # Convert :"en-US-x-12" to 'en-US'
    def initialize(code)
      @locale_id = if code.start_with?('en-US') # default locale
                     'en-US'
                   else
                     code.sub(/-x-.*/, '').downcase
      end
    end
  end
end

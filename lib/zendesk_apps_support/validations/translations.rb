require 'jshintrb'

module ZendeskAppsSupport
  module Validations
    module Translations
      class << self

        TRANSLATIONS_PATH = %r{^translations/(.*)\.json$}
        VALID_LOCALE = /^[a-z]{2,3}$/

        def call(package)
          package.files.inject([]) do |errors, file|
            if path_match = TRANSLATIONS_PATH.match(file.relative_path)
              errors << locale_error(file, path_match[1]) << json_error(file)
            end
            errors
          end.compact
        end

        private

        def locale_error(file, locale)
          return nil if VALID_LOCALE =~ locale
          ValidationError.new('translation.invalid_locale', :file => file.relative_path)
        end

        def json_error(file)
          json = MultiJson.load(file.read)
          return nil if json.kind_of?(Hash)
          ValidationError.new('translation.not_json_object', :file => file.relative_path)
        rescue MultiJson::DecodeError => e
          ValidationError.new('translation.not_json', :file => file.relative_path, :errors => e)
        end

      end
    end
  end
end

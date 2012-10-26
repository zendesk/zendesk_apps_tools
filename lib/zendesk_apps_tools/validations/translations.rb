require 'jshintrb'

module ZendeskAppsTools
  module Validations
    module Translations

      class <<self
        def call(package)
          package.translation_files.each_with_object([]) do |file, errors|
            jshint_errors = linter.lint( File.read(file) )
            if jshint_errors.any?
              errors << JSHintValidationError.new(package.relative_file_name(file), jshint_errors)
            end
          end
        end

        private

        def linter
          Jshintrb::Lint.new
        end
      end
    end
  end
end

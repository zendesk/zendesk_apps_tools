require 'jshintrb'

module ZendeskAppsSupport
  module Validations
    module Translations

      class <<self
        def call(package)
          package.translation_files.each_with_object([]) do |file, errors|
            jshint_errors = linter.lint(file.read)
            if jshint_errors.any?
              errors << JSHintValidationError.new(file.relative_path, jshint_errors)
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

require 'jshintrb'

module ZendeskAppsTools
  module Validations
    module Translations

      class <<self
        def call(package)
          package.translation_files.each_with_object([]) do |file, errors|
            jshint_errors = linter.lint( File.read(file) )

            if jshint_errors.any?
              detail = jshint_errors.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('')
              errors << ValidationError.new(
                          :jshint_errors,
                          :file => package.relative_file_name( file ),
                          :errors => detail,
                          :count => errors.length
                        )
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

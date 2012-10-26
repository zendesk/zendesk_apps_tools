require 'jshintrb'

module ZendeskAppsTools
  module Validations
    module Source

      LINTER_OPTIONS = {
        # enforcing options:
        :noarg => true,
        :undef => true,

        # relaxing options:
        :eqnull => true,
        :laxcomma => true,

        # predefined globals:
        :predef =>  %w(
            _ console services helpers alert json base64
            clearinterval cleartimeout setinterval settimeout
          )
      }.freeze

      class <<self
        def call(package)
          return [ ValidationError.new(:missing_source) ] unless File.exists?(package.source_path)

          errors = linter.lint( File.read(package.source_path) )

          if errors.any?
            detail = errors.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('')
            [
              ValidationError.new(
                :jshint_errors,
                :file => package.relative_file_name( package.source_path ),
                :errors => detail,
                :count => errors.length)
            ]
          else
            []
          end
        end

        private

        def linter
          Jshintrb::Lint.new(LINTER_OPTIONS)
        end

      end
    end
  end
end

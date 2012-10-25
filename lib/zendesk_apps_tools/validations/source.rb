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
          return ['No source found!'] unless File.exists?(package.source_path)

          errors = linter.lint( File.read(package.source_path) )

          if errors.any?
            [ "JSHint errors:" +
              errors.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('') ]
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

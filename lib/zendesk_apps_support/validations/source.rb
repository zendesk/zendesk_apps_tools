require 'jshintrb'

module ZendeskAppsSupport
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
        :predef => %w(_ console services helpers alert JSON Base64 clearInterval clearTimeout setInterval setTimeout)
      }.freeze

      class <<self
        def call(package)
          source = package.files.find { |f| f.relative_path == 'app.js' }

          return [ ValidationError.new(:missing_source) ] unless source

          jshint_errors = linter.lint(source.read)
          if jshint_errors.any?
            [ JSHintValidationError.new(source.relative_path, jshint_errors) ]
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

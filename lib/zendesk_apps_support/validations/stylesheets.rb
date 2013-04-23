require 'zendesk_apps_support/stylesheet_compiler'

module ZendeskAppsSupport
  module Validations
    module Stylesheets

      class << self

        def call(package)
          if css_error = validate_styles(package.customer_css)
            [css_error]
          else
            []
          end
        end

        private

        def validate_styles(css)
          compiler = ZendeskAppsSupport::StylesheetCompiler.new(css, nil, nil)
          begin
            compiler.compile
          rescue Sass::SyntaxError => e
            return ValidationError.new(:stylesheet_error, :sass_error => e.message)
          end
          nil
        end

      end
    end
  end
end

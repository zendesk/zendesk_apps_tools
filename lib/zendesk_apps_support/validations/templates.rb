module ZendeskAppsSupport
  module Validations
    module Templates

      class <<self
        def call(package)
          errors = []
          package.template_files.each do |template|
            contents = template.read
            if contents =~ /<\s*style\b/
              errors << ValidationError.new(:style_in_template, :template => template.relative_path)
            end
          end
          errors
        end
      end

    end
  end
end

module ZendeskAppsSupport
  module Validations
    module Templates

      class <<self
        def call(package)
          package.template_files.each_with_object([]) do |template, errors|
            contents = template.read
            if contents =~ /<\s*style\b/
              errors << ValidationError.new(:style_in_template, :template => template.relative_path)
            end
          end
        end
      end

    end
  end
end

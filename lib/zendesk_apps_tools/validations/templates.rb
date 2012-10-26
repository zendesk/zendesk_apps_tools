module ZendeskAppsTools
  module Validations
    module Templates

      class <<self
        def call(package)
          package.template_files.each_with_object([]) do |file, errors|
            relative_file_name = package.relative_file_name(file)
            puts "Checking #{relative_file_name}"
            contents = File.read(file)
            if contents =~ /<\s*style\b/
              errors << ValidationError.new(:style_in_template, :template => relative_file_name)
            end
          end
        end

      end
    end
  end
end

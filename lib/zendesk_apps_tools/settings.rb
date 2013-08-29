require 'zendesk_apps_tools/common'

module ZendeskAppsTools
  module Settings
    include ZendeskAppsTools::Common

    def settings_for_parameters(parameters)
      return {} if parameters.nil?

      parameters.inject({}) do |settings, param|
        if param[:default]
          stdin = get_value_from_stdin("Enter a value for parameter '#{param[:name]}' or press 'Return' to use the default value '#{param[:default]}':\n", :allow_empty => true)
          input = param[:default] if stdin.empty?
        elsif param[:required]
          input = get_value_from_stdin("Enter a value for required parameter '#{param[:name]}':\n")
        else
          input = get_value_from_stdin("Enter a value for optional parameter '#{param[:name]}' or press 'Return' to skip:\n", :allow_empty => true)
        end

        unless input.empty?
          input = (input =~ /^(true|t|yes|y|1)$/i) ? true : false if param[:type] == 'checkbox'
          settings[param[:name]] = input
        end

        settings
      end
    end

  end
end


require 'zendesk_apps_tools/common'
require 'yaml'

module ZendeskAppsTools
  class Settings

    def get_settings_from(user_input, parameters)
      return {} if parameters.nil?

      parameters.inject({}) do |settings, param|
        if param[:default]
          input = user_input.get_value_from_stdin("Enter a value for parameter '#{param[:name]}' or press 'Return' to use the default value '#{param[:default]}':\n", :allow_empty => true)
          input = param[:default] if input.empty?
        elsif param[:required]
          input = user_input.get_value_from_stdin("Enter a value for required parameter '#{param[:name]}':\n")
        else
          input = user_input.get_value_from_stdin("Enter a value for optional parameter '#{param[:name]}' or press 'Return' to skip:\n", :allow_empty => true)
        end

        if param[:type] == 'checkbox'
          input = convert_to_boolean_for_checkbox(input)
        end

        settings[param[:name]] = input if input != ''
        settings
      end
    end

    def get_settings_yaml(path, parameters)
      return {} if parameters.nil?

      begin
        settingsFile = File.read(File.join( path, 'config', 'settings.yaml'))
        settings = YAML::load(settingsFile)
        settings.each do |index, setting|
          if (setting.is_a?(Hash) || setting.is_a?(Array))
            settings[index] = JSON.dump(setting)
          end
        end
      rescue => err
        return {}
      end
    end

    private

    def convert_to_boolean_for_checkbox(input)
      if ![TrueClass, FalseClass].include?(input.class)
        return (input =~ /^(true|t|yes|y|1)$/i) ? true : false
      end
      input
    end

  end
end


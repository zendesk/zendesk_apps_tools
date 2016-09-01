require 'zendesk_apps_tools/common'
require 'yaml'

module ZendeskAppsTools
  class Settings
    def initialize(cli)
      @cli = cli
    end

    def get_settings_from_user_input(parameters)
      return {} if parameters.nil?

      parameters.inject({}) do |settings, param|
        if param['default']
          input = @cli.get_value_from_stdin("Enter a value for parameter '#{param['name']}' or press 'Return' to use the default value '#{param['default']}':\n", allow_empty: true)
          input = param['default'] if input.empty?
        elsif param['required']
          input = @cli.get_value_from_stdin("Enter a value for required parameter '#{param['name']}':\n")
        else
          input = @cli.get_value_from_stdin("Enter a value for optional parameter '#{param['name']}' or press 'Return' to skip:\n", allow_empty: true)
        end

        if param['type'] == 'checkbox'
          input = convert_to_boolean_for_checkbox(input)
        end

        settings[param['name']] = input if input != ''
        settings
      end
    end

    def refresh!
      if File.exist? @filepath
        curr_mtime = File.stat(@filepath).mtime
        if curr_mtime > @last_mtime
          @last_mtime = curr_mtime
          get_settings_from_file(@filepath, @parameters)
        end
      end
    end

    def get_settings_from_file(filepath, parameters)
      @filepath ||= filepath
      @parameters ||= parameters

      return {} if parameters.nil?
      return nil unless File.exist? filepath

      begin
        @last_mtime = File.stat(filepath).mtime
        settings_file = File.read(filepath)

        if filepath =~ /\.json$/ || settings_file =~ /\A\s*{/
          settings_data = JSON.load(settings_file)
        else
          settings_data = YAML.load(settings_file)
        end

        settings_data.each do |index, setting|
          if setting.is_a?(Hash) || setting.is_a?(Array)
            settings_data[index] = JSON.dump(setting)
          end
        end
      rescue => err
        @cli.say_error "Failed to load #{filepath}"
        @cli.say_error err.message
        return nil
      end

      parameters.inject({}) do |settings, param|
        input = settings_data[param['name']]

        if !input && param['default']
          input = param['default']
        end

        if !input && param['required']
          @cli.say_error "'#{param['name']}' is required but not specified in the config file.\n"
          return nil
        end

        if param['type'] == 'checkbox'
          input = convert_to_boolean_for_checkbox(input)
        end

        settings[param['name']] = input if input != ''
        settings
      end
    end

    private

    def convert_to_boolean_for_checkbox(input)
      unless [TrueClass, FalseClass].include?(input.class)
        return (input =~ /^(true|t|yes|y|1)$/i) ? true : false
      end
      input
    end
  end
end

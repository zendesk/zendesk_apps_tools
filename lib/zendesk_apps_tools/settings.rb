require 'zendesk_apps_tools/common'

module ZendeskAppsTools
  class Settings
    def initialize(cli)
      @cli = cli
    end

    def get_settings_from_user_input(parameters)
      return {} if parameters.nil?

      parameters.inject({}) do |settings, param|
        if param.key? 'default'
          input = @cli.get_value_from_stdin("Enter a value for parameter '#{param['name']}':\n", default: param['default'])
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
      return unless File.file? @filepath
      curr_mtime = File.stat(@filepath).mtime
      if @last_mtime.nil? || curr_mtime > @last_mtime
        @last_mtime = curr_mtime
        get_settings_from_file(@filepath, @parameters)
      end
    end

    def get_settings_from_file(filepath, parameters)
      @filepath ||= filepath
      @parameters ||= parameters

      return {} if parameters.nil?
      return nil unless File.exist? filepath

      begin
        settings_file = read_settings(filepath)
        settings_data = parse_settings(filepath, settings_file)
      rescue => err
        @cli.say_error "Failed to load #{filepath}\n#{err.message}"
        return nil
      end

      parameters.each_with_object({}) do |param, settings|
        input = settings_data.fetch(param['name'], param['default'])

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

    def read_settings(filepath)
      @last_mtime = File.stat(filepath).mtime
      File.read(filepath)
    end

    def parse_settings(filepath, contents)
      settings_data =
        if filepath =~ /\.json$/ || contents =~ /\A\s*{/
          JSON.load(contents)
        else
          require 'yaml'
          YAML.load(contents)
        end
      settings_data.each do |index, setting|
        if setting.is_a?(Hash) || setting.is_a?(Array)
          settings_data[index] = JSON.dump(setting)
        end
      end
      settings_data
    end

    def convert_to_boolean_for_checkbox(input)
      unless [TrueClass, FalseClass].include?(input.class)
        return (input =~ /^(true|t|yes|y|1)$/i) ? true : false
      end
      input
    end
  end
end

require 'thor'

module ZendeskAppsTools
  class Translate < Thor
    include Thor::Shell
    include Thor::Actions

    desc 'create', 'Create Zendesk translation file from en.json'
    def create
      manifest = JSON.parse(File.open('manifest.json').read)
      app_name = manifest['name']

      unless app_name
        app_name = get_value_from_stdin('What is the name of this app?', /^\w.*$/, "Invalid name, try again:")
      end

      package = get_value_from_stdin('What is the package name for this app?', /^[a-z_]+$/, "Invalid package name, try again:")

      write_yaml(app_name, package)
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), "../.."))
    end

    no_commands do

      def get_value_from_stdin(prompt, valid_regex, error_msg)
        while input = ask(prompt)
          unless input =~ valid_regex
            say(error_msg, :red)
          else
            break
          end
        end

        return input
      end

      def write_yaml(app_name, package)
        user_translations = JSON.parse(File.open('translations/en.json').read)
        @translations = user_translations.keys.inject({}) do |translations, key|
          translations.merge( get_translations_for(user_translations, key) )
        end

        @app_name = app_name
        @package_name = package
        template(File.join(Translate.source_root, 'template/translation.erb.tt'), "translations/en.yml")
      end

      def get_translations_for(scope, scope_key, keys = [], translations = {})
        hash_or_value = scope[scope_key]

        if hash_or_value.is_a?(Hash)
          keys << scope_key
          hash_or_value.each_key do |key|

            if hash_or_value[key].is_a?(Hash)
              get_translations_for(hash_or_value, key, keys, translations)
              keys = keys[0...-1]
            else
              translation_key = (keys + [key]).join('.')
              translations[translation_key] = hash_or_value[key]
            end

          end
        else
          translations[scope_key] = hash_or_value
        end

        translations
      end

    end
  end
end

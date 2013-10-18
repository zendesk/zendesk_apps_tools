require 'thor'
require 'json'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/locale_identifier'

module ZendeskAppsTools
  class Translate < Thor
    include Thor::Shell
    include Thor::Actions
    include ZendeskAppsTools::Common

    CHARACTERS_TO_ESCAPE = %w[ " ]
    LOCALE_ENDPOINT = "https://support.zendesk.com/api/v2/locales/agent.json"

    desc 'create', 'Create Zendesk translation file from en.json'
    def create
      manifest = JSON.parse(File.open('manifest.json').read)
      app_name = manifest['name']

      unless app_name
        app_name = get_value_from_stdin('What is the name of this app?', :error_msg => "Invalid name, try again:")
      end

      package = get_value_from_stdin('What is the package name for this app?', :valid_regex => /^[a-z_]+$/, :error_msg => "Invalid package name, try again:")

      write_yaml(app_name, package)
    end

    desc 'update', 'Update translation files from Zendesk'
    def update(request_builder = Faraday.new)
      app_package = get_value_from_stdin("What is the package name for this app? (without app_)", :valid_regex => /^[a-z_]+$/, :error_msg => "Invalid package name, try again:")

      user = "#{user}/token"
      key_prefix = "txt.apps.#{app_package}."

      say("Fetching translations...")
      locale_response = api_request(LOCALE_ENDPOINT, request_builder)

      if locale_response.status == 200
        locales = JSON.parse(locale_response.body)["locales"]

        locales.each do |locale|
          locale_url = "#{locale["url"]}?include=translations&packages=app_#{app_package}"
          locale_response = api_request(locale_url, request_builder).body
          translations = JSON.parse(locale_response)['locale']['translations']

          locale_name = ZendeskAppsTools::LocaleIdentifier.new(locale['locale']).language_id
          write_json(locale_name, nest_translations_hash(translations, key_prefix))
        end
        say("Translations updated", :green)

      elsif locale_response.status == 401
        say("Authentication failed", :red)
      end
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), "../.."))
    end

    no_commands do

      def write_json(locale_name, translations_hash)
        create_file("translations/#{locale_name}.json", JSON.pretty_generate(translations_hash))
      end

      def nest_translations_hash(translations_hash, key_prefix)
        result = {}

        translations_hash.each do |full_key, value|
          parts = full_key.gsub(key_prefix, '').split('.')
          parts_count = parts.size - 1
          context = result

          parts.each_with_index do |part, i|

            if parts_count == i
              context[part] = value
            else
              context = context[part] ||= {}
            end

          end
        end

        result
      end

      def write_yaml(app_name, package)
        user_translations = JSON.parse(File.open('translations/en.json').read)
        translations = user_translations.keys.inject({}) do |translations, key|
          translations.merge( get_translations_for(user_translations, key) )
        end
        @escaped_translations = escape_values(translations)

        @app_name = app_name
        @package_name = package
        template(File.join(Translate.source_root, 'templates/translation.erb.tt'), "translations/en.yml")
      end

      def escape_values(translations)
        result = {}
        translations.each do |key, value|
          CHARACTERS_TO_ESCAPE.each do |char|
            result[key] = value.gsub(char, "\\#{char}")
          end
        end

        result
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

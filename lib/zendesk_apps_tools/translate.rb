require 'thor'
require 'json'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/locale_identifier'
require 'zendesk_apps_support'
require 'yaml'

module ZendeskAppsTools
  class Translate < Thor
    include Thor::Shell
    include Thor::Actions
    include ZendeskAppsTools::Common
    include ZendeskAppsSupport::BuildTranslation

    LOCALE_ENDPOINT = 'https://support.zendesk.com/api/v2/locales/agent.json'

    desc 'to_yml', 'Create Zendesk translation file from en.json'
    method_option :path, default: './', required: false
    def to_yml
      setup_path(options[:path]) if options[:path]
      manifest = JSON.parse(File.open("#{destination_root}/manifest.json").read)
      app_name = manifest['name']

      unless app_name
        app_name = get_value_from_stdin('What is the name of this app?', error_msg: 'Invalid name, try again:')
      end

      en_json = JSON.parse(File.open("#{destination_root}/translations/en.json").read)

      package = en_json['app']['package']
      say('No package defined inside en.json! Abort.', :red) and exit 1 unless package
      en_json['app'].delete('package')

      write_yml(en_json, app_name, package)
    end

    desc 'to_json', 'Convert Zendesk translation yml to I18n formatted json'
    method_option :path, default: './', required: false
    def to_json
      setup_path(options[:path]) if options[:path]
      en_yml = YAML.load_file("#{destination_root}/translations/en.yml")
      package = /^txt.apps.([^\.]+)/.match(en_yml['parts'][0]['translation']['key'])[1]
      translations = en_yml['parts'].map { |part| part['translation'] }
      en_json = array_to_nested_hash(translations)['txt']['apps'][package]
      en_json['app']['package'] = package

      write_json('translations/en.json', en_json)
    end

    desc 'update', 'Update translation files from Zendesk'
    method_option :path, default: './', required: false
    def update(request_builder = Faraday.new)
      setup_path(options[:path]) if options[:path]
      app_package = get_value_from_stdin('What is the package name for this app? (without app_)', valid_regex: /^[a-z_]+$/, error_msg: 'Invalid package name, try again:')

      key_prefix = "txt.apps.#{app_package}."

      say('Fetching translations...')
      locale_response = api_request(LOCALE_ENDPOINT, request_builder)

      if locale_response.status == 200
        locales = JSON.parse(locale_response.body)['locales']

        locales.each do |locale|
          locale_url      = "#{locale['url']}?include=translations&packages=app_#{app_package}"
          locale_response = api_request(locale_url, request_builder).body
          translations    = JSON.parse(locale_response)['locale']['translations']

          locale_name = ZendeskAppsTools::LocaleIdentifier.new(locale['locale']).locale_id
          write_json("#{destination_root}/translations/#{locale_name}.json", nest_translations_hash(translations, key_prefix))
        end
        say('Translations updated', :green)

      elsif locale_response.status == 401
        say('Authentication failed', :red)
      end
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), '../..'))
    end

    no_commands do
      def setup_path(path)
        @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
      end

      def write_json(filename, translations_hash)
        create_file(filename, JSON.pretty_generate(translations_hash) + "\n")
      end

      def nest_translations_hash(translations_hash, key_prefix)
        result = {}

        translations_hash.each do |full_key, value|
          parts       = full_key.gsub(key_prefix, '').split('.')
          parts_count = parts.size - 1
          context     = result

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

      def write_yml(en_json, app_name, package_name)
        titles        = to_flattened_namespaced_hash(en_json, I18N_TITLE_KEY)
        values        = to_flattened_namespaced_hash(en_json, I18N_VALUE_KEY)
        @translations = titles.each { |k, v| titles[k] = { 'title' => v, 'value' => escape_special_characters(values[k]) } }
        @app_name     = app_name
        @package_name = package_name
        template(File.join(Translate.source_root, 'templates/translation.erb.tt'), 'translations/en.yml')
      end

      def escape_special_characters(v)
        v.gsub('"', '\"')
      end

      def array_to_nested_hash(array)
        array.inject({}) do |result, item|
          keys = item['key'].split('.')
          current = result
          keys[0..-2].each do |key|
            current = (current[key] ||= {})
          end
          current[keys[-1]] = { 'title' => item['title'], 'value' => item['value'] }
          result
        end
      end
    end
  end
end

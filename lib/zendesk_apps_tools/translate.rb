# frozen_string_literal: true
require 'thor'
require 'json'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/locale_identifier'

module ZendeskAppsTools
  class Translate < Thor
    include Thor::Shell
    include Thor::Actions
    include ZendeskAppsTools::Common

    LOCALE_BASE_ENDPOINT = 'https://support.zendesk.com/api/v2/locales'
    LOCALE_ENDPOINT = "#{LOCALE_BASE_ENDPOINT}/agent.json"

    desc 'to_yml', 'Create Zendesk translation file from en.json'
    shared_options(except: [:clean])
    def to_yml
      setup_path(options[:path]) if options[:path]
      manifest = JSON.parse(File.open("#{destination_root}/manifest.json").read)
      app_name = manifest['name']

      unless app_name
        app_name = get_value_from_stdin('What is the name of this app?', error_msg: 'Invalid name, try again:')
      end

      package = package_name_from_json(error_out: true)
      en_json['app'].delete('package')

      write_yml(en_json, app_name, package)
    end

    desc 'to_json', 'Convert Zendesk translation yml to I18n formatted json'
    shared_options(except: [:clean])
    def to_json
      require 'yaml'
      setup_path(options[:path]) if options[:path]
      en_yml = YAML.load_file("#{destination_root}/translations/en.yml")
      package = /^txt.apps.([^\.]+)/.match(en_yml['parts'][0]['translation']['key'])[1]
      translations = en_yml['parts'].map { |part| part['translation'] }
      translations.select! do |translation|
        obsolete = translation['obsolete']
        next true unless obsolete
        Date.parse(obsolete.to_s) > Date.today
      end
      en_hash = array_to_nested_hash(translations)['txt']['apps'][package]
      en_hash['app']['package'] = package

      write_json('translations/en.json', en_hash)
    end

    desc 'update', 'Update translation files from Zendesk'
    shared_options(except: [:clean])
    method_option :package_name, type: :string
    method_option :locales, type: :string, desc: 'Path to a JSON file that has a list of locales'
    def update
      setup_path(options[:path]) if options[:path]
      app_package = package_name_for_update
      locale_list
        .map { |locale| fetch_locale_async locale, app_package }
        .each do |locale_thread|
          locale = locale_thread.value
          translations = locale['translations']

          locale_name = ZendeskAppsTools::LocaleIdentifier.new(locale['locale']).locale_id
          write_json(
            "translations/#{locale_name}.json",
            nest_translations_hash(translations, "txt.apps.#{app_package}.")
          )
        end
      say('Translations updated', :green)
    end

    desc 'pseudotranslate', 'Generate a Pseudo-translation to use for testing. This will pretend to be French.'
    shared_options(except: [:clean])
    def pseudotranslate
      setup_path(options[:path]) if options[:path]

      package = package_name_from_json(error_out: true)

      pseudo = build_pseudotranslation(en_json, package)
      write_json('translations/fr.json', pseudo)
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), '../..'))
    end

    no_commands do
      def fetch_locale_async(locale, app_package)
        Thread.new do
          say("Fetching #{locale['locale']}")
          json = Faraday.get("#{locale['url']}?include=translations&packages=app_#{app_package}").body
          json_or_die(json)['locale']
        end
      end

      def setup_path(path)
        @destination_stack << relative_to_original_destination_root(path) unless @destination_stack.last == path
      end

      def write_json(filename, translations_hash)
        create_file(filename, JSON.pretty_generate(translations_hash).force_encoding('ASCII-8BIT') + "\n", force: options[:unattended])
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
        titles        = to_flattened_namespaced_hash(en_json, :title)
        values        = to_flattened_namespaced_hash(en_json, :value)
        @translations = titles.each do |k, v|
          titles[k] = { 'title' => v, 'value' => escape_special_characters(values[k]) }
        end
        @app_name     = app_name
        @package_name = package_name
        template(File.join(Translate.source_root, 'templates/translation.erb.tt'), 'translations/en.yml')
      end

      def escape_special_characters(v)
        v.gsub('"', '\"')
      end

      def to_flattened_namespaced_hash(hash, target_key)
        require 'zendesk_apps_support/build_translation'
        @includer_class ||= Class.new { include ZendeskAppsSupport::BuildTranslation }
        target_key_constant = case target_key
                              when :title
                                @includer_class::I18N_TITLE_KEY
                              when :value
                                @includer_class::I18N_VALUE_KEY
                              end
        (@includer ||= @includer_class.new)
          .to_flattened_namespaced_hash(hash, target_key_constant)
      end

      def array_to_nested_hash(array)
        array.each_with_object({}) do |item, result|
          keys = item['key'].split('.')
          current = result
          keys[0..-2].each do |key|
            current = (current[key] ||= {})
          end
          current[keys[-1]] = { 'title' => item['title'], 'value' => item['value'] }
          result
        end
      end

      def build_pseudotranslation(translations_hash, package_name)
        titles       = to_flattened_namespaced_hash(translations_hash, :title)
        values       = to_flattened_namespaced_hash(translations_hash, :value)
        translations = titles.each { |k, v| titles[k] = { 'title' => v, 'value' => "[日本#{values[k]}éñđ]" } }
        translations['app.package'] = package_name # don't pseudo translate the package name
        nest_translations_hash(translations, '')
      end

      def locale_list
        say('Fetching translations...')
        require 'net/http'
        require 'faraday'

        if options[:locales]
          content = File.read(File.expand_path(options[:locales]))
          locales = JSON.parse(content)
          return locales.map do |locale|
            { 'locale' => locale, 'url' => "#{LOCALE_BASE_ENDPOINT}/#{locale}.json" }
          end
        end

        locale_response = Faraday.get(LOCALE_ENDPOINT)

        return json_or_die(locale_response.body)['locales'] if locale_response.status == 200
        if locale_response.status == 401
          say_error_and_exit 'Authentication failed'
        else
          say_error_and_exit "Failed to download locales, got HTTP status #{locale_response.status}"
        end
      end

      def package_name_for_update
        options[:package_name] ||
          package_name_from_json(error_out: options[:unattended]) ||
          get_value_from_stdin('What is the package name for this app? (without leading app_)',
                               valid_regex: /^[a-z_]+$/,
                               error_msg: 'Invalid package name, try again:')
      end

      def en_json
        @en_json ||= begin
          path = "#{destination_root}/translations/en.json"
          JSON.parse(File.open(path).read) if File.exist? path
        end
      end

      def package_name_from_json(error_out: false)
        package = en_json && en_json['app']['package']
        return package if package
        say_error_and_exit 'No package defined inside en.json!' if error_out
      end
    end
  end
end

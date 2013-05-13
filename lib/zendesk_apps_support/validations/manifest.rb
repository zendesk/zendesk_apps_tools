require 'multi_json'

module ZendeskAppsSupport
  module Validations
    module Manifest

      REQUIRED_MANIFEST_FIELDS = %w( author defaultLocale location frameworkVersion).freeze
      LOCATIONS_AVAILABLE      = %w( nav_bar ticket_sidebar new_ticket_sidebar ).freeze

      class <<self
        def call(package)
          manifest = package.files.find { |f| f.relative_path == 'manifest.json' }

          return [ValidationError.new(:missing_manifest)] unless manifest

          manifest = MultiJson.load(manifest.read)

          [].tap do |errors|
            errors << missing_keys_error(manifest)
            errors << default_locale_error(manifest, package)
            errors << invalid_location_error(manifest)
            errors << parameters_error(manifest)
            errors << invalid_hidden_parameter_error(manifest)
            errors.compact!
          end
        rescue MultiJson::DecodeError => e
          return [ValidationError.new(:manifest_not_json, :errors => e)]
        end

        private

        def parameters_error(manifest)
          return unless manifest['parameters']

          unless manifest['parameters'].kind_of?(Array)
            return ValidationError.new(:parameters_not_an_array)
          end

          para_names = manifest['parameters'].collect{|para| para['name']}
          duplicate_parameters = para_names.select {|name| para_names.count(name) > 1}.uniq
          unless duplicate_parameters.empty?
            return ValidationError.new(:duplicate_parameters, :duplicate_parameters => duplicate_parameters)
          end
        end

        def missing_keys_error(manifest)
          missing = REQUIRED_MANIFEST_FIELDS.select do |key|
            manifest[key].nil?
          end

          if missing.any?
            ValidationError.new('manifest_keys.missing', :missing_keys => missing.join(', '), :count => missing.length)
          end
        end

        def default_locale_error(manifest, package)
          default_locale = manifest['defaultLocale']
          if !default_locale.nil?
            if default_locale !~ /^[a-z]{2,3}$/
              ValidationError.new(:invalid_default_locale, :defaultLocale => default_locale)
            elsif package.translation_files.detect { |file| file.relative_path == "translations/#{default_locale}.json" }.nil?
              ValidationError.new(:missing_translation_file, :defaultLocale => default_locale)
            end
          end
        end

        def invalid_location_error(manifest)
          invalid_locations = [*manifest['location']] - LOCATIONS_AVAILABLE
          unless invalid_locations.empty?
            ValidationError.new(:invalid_location, :invalid_locations => invalid_locations.join(', '), :count => invalid_locations.length)
          end
        end

        def invalid_hidden_parameter_error(manifest)
          invalid_params = []

          if manifest.has_key?('parameters')
            invalid_params = manifest['parameters'].select { |p| p['type'] == 'hidden' && p['required'] }.map { |p| p['name'] }
          end

          if invalid_params.any?
            ValidationError.new(:invalid_hidden_parameter, :invalid_params => invalid_params.join(', '), :count => invalid_params.length)
          end
        end

      end
    end
  end
end

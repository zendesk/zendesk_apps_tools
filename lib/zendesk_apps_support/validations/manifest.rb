require 'multi_json'

module ZendeskAppsSupport
  module Validations
    module Manifest

      REQUIRED_MANIFEST_FIELDS = %w( author defaultLocale location frameworkVersion).freeze

      class <<self
        def call(package)
          manifest = package.files.find { |f| f.relative_path == 'manifest.json' }

          return [ ValidationError.new(:missing_manifest) ] unless manifest

          manifest = MultiJson.load(manifest.read)
          missing = missing_keys(manifest)
          return [ ValidationError.new(:missing_manifest_keys, :missing_keys => missing.join(', '), :count => missing.length) ] if missing.any?

          []
        rescue MultiJson::DecodeError => e
          return [ ValidationError.new(:manifest_not_json, :errors => e) ]
        end

        private

        def missing_keys(manifest)
          REQUIRED_MANIFEST_FIELDS.select do |key|
            manifest[key].nil?
          end
        end

      end
    end
  end
end

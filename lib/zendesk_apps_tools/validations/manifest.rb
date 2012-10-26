module ZendeskAppsTools
  module Validations
    module Manifest

      REQUIRED_MANIFEST_FIELDS = %w( author default_locale ).freeze

      class <<self
        def call(package)
          return [ ValidationError.new(:missing_manifest) ] unless File.exists?(package.manifest_path)

          manifest = MultiJson.load( File.read(package.manifest_path) )
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

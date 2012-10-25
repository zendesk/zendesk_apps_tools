module ZendeskAppsTools
  module Validations
    module Manifest

      REQUIRED_MANIFEST_FIELDS = %w( author default_locale ).freeze

      class <<self
        def call(package)
          return ['No manifest found!'] unless File.exists?(package.manifest_path)

          manifest = MultiJson.load( File.read(package.manifest_path) )
          missing = missing_keys(manifest)
          return [ "Missing keys in manifest: #{missing.join(', ')}" ] if missing.any?

          []
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

require 'zendesk_apps_tools/array_patch'

module ZendeskAppsTools
  module ManifestHandler
    VERSION_PARTS = %i(major minor patch)

    attr_reader :semver

    VERSION_PARTS.each do |m|
      define_method m do
        load_manifest
        read_version
        normalize_version
        super()
        update_version
        write_manifest
        post_actions
      end
    end

    private

    def manifest_json_path
      'manifest.json'
    end

    def load_manifest
      require 'json'
      manifest_json = File.read(manifest_json_path)
      @manifest = JSON.load(manifest_json)
    rescue => e
      say(e.message, :red) and exit 1
    end

    def read_version
      version = @manifest.fetch('version', '0.0.0')
      sem_parts = sub_semver(version)
      @semver = sem_parts.names.map(&:to_sym).zip(sem_parts.to_a.drop(1)).to_h
    end

    def normalize_version
      VERSION_PARTS.each do |part|
        semver[part] = (semver[part] || '0').to_i
      end
    end

    def update_version
      @manifest['version'] = version
    end

    def write_manifest
      File.open(manifest_json_path, 'w') do |f|
        f.write(JSON.pretty_generate(@manifest))
        f.write("\n")
      end
    end

    def sub_semver(v)
      v.match(/\A(?<v>v)?(?<major>\d+)(?:\.(?<minor>\d+)(?:\.(?<patch>\d+))?)?\Z/)
    end

    def version(v: false)
      [
        v ? 'v' : semver[:v],
        [
          semver[:major],
          semver[:minor],
          semver[:patch]
        ].compact.map(&:to_s).join('.')
      ].compact.join
    end
  end
end

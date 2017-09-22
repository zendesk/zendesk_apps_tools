module ZendeskAppsTools
  module Theming
    module Common
      def theme_package_path(*file)
        File.expand_path(File.join(app_dir, *file))
      end

      def url_for(package_file)
        relative_path = relative_path_for(package_file)
        path_parts = recursive_pathname_split(relative_path)
        path_parts.shift
        "http://localhost:4567/guide/#{path_parts.join('/')}"
      end

      def relative_path_for(filename)
        Pathname.new(filename).relative_path_from(Pathname.new(File.expand_path(app_dir))).cleanpath
      end

      def assets
        assets = Dir.glob(theme_package_path('assets', '*'))
        assets.each_with_object({}) do |asset, asset_payload|
          asset_payload[File.basename(asset)] = url_for(asset)
        end
      end

      def assets_hash
        assets.each_with_object({}) do |(k,v), h|
          parametrized = k.gsub(/[^a-z0-9\-_]+/, '-')
          h["assets-#{parametrized}"] = v
        end
      end

      def manifest
        full_manifest_path = theme_package_path('manifest.json')
        JSON.parse(File.read(full_manifest_path))
      rescue Errno::ENOENT
        say_error_and_exit "There's no manifest file in #{full_manifest_path}"
      rescue JSON::ParserError
        say_error_and_exit "The manifest file is invalid at #{full_manifest_path}"
      end

      def settings_hash
        manifest['settings'].flat_map { |setting_group| setting_group['variables'] }.each_with_object({}) do |variable, result|
          result[variable.fetch('identifier')] = value_for_setting(variable)
        end
      end

      def value_for_setting(variable)
        return variable.fetch('value') unless variable.fetch('type') == 'file'

        files = Dir.glob(theme_package_path('settings', '*.*'))
        file = files.find { |f| File.basename(f, '.*') == variable.fetch('identifier') }
        url_for(file)
      end

      def recursive_pathname_split(relative_path)
        split_path = relative_path.split
        joined_directories = split_path[0]
        return split_path if split_path[0] == joined_directories.split[0]
        [*recursive_pathname_split(joined_directories), split_path[1]]
      end
    end
  end
end

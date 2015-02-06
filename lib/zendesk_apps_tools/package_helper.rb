module ZendeskAppsTools
  require 'zendesk_apps_support'

  module PackageHelper
    include ZendeskAppsSupport

    def app_package
      @app_package ||= Package.new(app_dir.to_s)
    end

    def zip(archive_path)
      Zip::ZipFile.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          path = file.relative_path
          say_status 'package', "adding #{path}"

          # resolve symlink to source path
          if File.symlink? file.absolute_path
            path = File.expand_path(File.readlink(file.absolute_path), File.dirname(file.absolute_path))
          end
          zipfile.add(file.relative_path, app_dir.join(path).to_s)
        end
      end
    end
  end
end

module ZendeskAppsTools

  module PackageHelper
    def app_package
      require 'zendesk_apps_support'
      @app_package ||= ZendeskAppsSupport::Package.new(app_dir.to_s)
    end

    def manifest
      app_package.manifest
    end

    def zip(archive_path)
      require 'zip'
      Zip::File.open(archive_path, 'w') do |zipfile|
        app_package.files.each do |file|
          relative_path = file.relative_path
          path = relative_path
          say_status 'package', "adding #{path}"

          # resolve symlink to source path
          if File.symlink? file.absolute_path
            path = File.expand_path(File.readlink(file.absolute_path), File.dirname(file.absolute_path))
          end
          if file.to_s == 'app.scss'
            relative_path = relative_path.sub 'app.scss', 'app.css'
          end
          zipfile.add(relative_path, app_dir.join(path).to_s)
        end
      end
    end
  end
end

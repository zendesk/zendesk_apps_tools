require 'sinatra/base'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :protection, :except => :frame_options
    set :public_folder, proc { "#{settings.root}/assets" }
    last_mtime = Time.new(0)

    get '/app.js' do
      content_type 'text/javascript'

      if File.exists? settings.config
        curr_mtime = File.stat(settings.config).mtime
        if curr_mtime > last_mtime
          settings_helper = ZendeskAppsTools::Settings.new
          settings.parameters = settings_helper.get_settings_from_file(settings.config, settings.manifest)
          last_mtime = curr_mtime
        end
      end

      package = ZendeskAppsSupport::Package.new(settings.root, false)
      installation = ZendeskAppsSupport::Installation.new(
        id: settings.app_id,
        app_id: settings.app_id,
        app_name: package.manifest_json['name'] || 'Local App',
        enabled: true,
        requirements: package.requirements_json,
        settings: settings.parameters,
        updated_at: Time.now.iso8601,
        created_at: Time.now.iso8601
      )

      app_js = package.compile_js(
        app_id: settings.app_id,
        app_name: package.manifest_json['name'] || 'Local App',
        assets_dir: "http://localhost:#{settings.port}/",
        locale: params['locale']
      )

      ZendeskAppsSupport::Installed.new([app_js], [installation]).compile_js
    end
  end
end

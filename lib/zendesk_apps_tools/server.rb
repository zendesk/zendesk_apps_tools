require 'sinatra/base'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
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

      ZendeskAppsSupport::Package.new(settings.root).readified_js(nil, settings.app_id, "http://localhost:#{settings.port}/", settings.parameters)
    end
  end
end

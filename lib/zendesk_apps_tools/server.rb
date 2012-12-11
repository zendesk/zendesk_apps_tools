require 'sinatra/base'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :public_folder, Proc.new {"#{settings.root}/app/assets"}

    get '/app.js' do
      content_type 'text/javascript'
      ZendeskAppsSupport::Package.new("#{settings.root}/app").readified_js(nil, 0, "http://localhost:#{settings.port}")
    end

  end
end
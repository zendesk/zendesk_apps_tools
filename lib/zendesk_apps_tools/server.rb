require 'sinatra/base'
require 'zendesk_apps_support/package'

class Server < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :port, ZendeskAppsTools::Command.port

  get '/app.js' do
    content_type 'text/javascript'
    ZendeskAppsSupport::Package.new(ZendeskAppsTools::Command.path + "/app").readified_js(nil, 0, "http://localhost:#{ZendeskAppsTools::Command.port}")
  end

  get '*.png' do
    content_type 'image/png'
    File.read("#{ZendeskAppsTools::Command.path}/app/assets/#{params[:splat][0]}.png")
  end

  run!
end

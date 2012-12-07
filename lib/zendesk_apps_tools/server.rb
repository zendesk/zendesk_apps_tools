require 'sinatra/base'
require 'erb'
require 'json'
require 'zendesk_apps_support/package'

class Server < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :port, ZendeskAppsTools::Command.port

  get '/app.js' do
    manifest = JSON.parse(File.read("#{ZendeskAppsTools::Command.path}/app/manifest.json"))
    @source = File.read("#{ZendeskAppsTools::Command.path}/app/app.js")
    @name = manifest["name"]
    @location = manifest["location"]
    @asset_url_prefix = "http://localhost:#{ZendeskAppsTools::Command.port}"
    @app_class_name = "app-0"
    @author = manifest["author"]
    @translations = {"app" => {}}
    @framework_version = manifest["frameworkVersion"]

    package = ZendeskAppsSupport::Package.new(ZendeskAppsTools::Command.path + "/app")
    @templates = package.compiled_templates(0, "http://localhost:#{ZendeskAppsTools::Command.port}")

    @settings = {}
    manifest["parameters"].select {|param| param["default"]} .inject(@settings) {|hash, element| hash[element["name"]] = element["default"]}
    @settings["title"] = @name

    erb 'src.js'.to_sym, :content_type => 'text/javascript'
  end

  get '*.png' do
    content_type 'image/png'
    File.read("#{ZendeskAppsTools::Command.path}/app/assets/#{params[:splat][0]}.png")
  end

  run!
end

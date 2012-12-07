require 'sinatra/base'
require 'erb'
require 'json'

class MyApp < Sinatra::Base
  DEFAULT_SCSS   = File.read(File.expand_path('../default_styles.scss', __FILE__))

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

    customer_css = File.read("#{ZendeskAppsTools::Command.path}/app/app.css")
    css = ZendeskAppsTools::StylesheetCompiler.new(DEFAULT_SCSS + customer_css, 0).compile

    @templates = begin
      Dir["#{ZendeskAppsTools::Command.path}/app/templates/*.hdbs"].inject({}) do |h, file|
        str = File.read(file)
        str.chomp!
        h[File.basename(file, File.extname(file))] = str
        h
      end
    end

    @templates.tap do |templates|
      templates['layout'] = "<style>\n#{css}</style>\n#{templates['layout']}"
    end

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

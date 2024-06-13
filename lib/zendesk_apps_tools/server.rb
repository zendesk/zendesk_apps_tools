require 'sinatra/base'
require 'sinatra/cross_origin'
require 'zendesk_apps_support' # dependency of zendesk_apps_support/package
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :server, :thin
    set :logging, true
    set :protection, except: :frame_options
    ZENDESK_DOMAINS_REGEX = %r{^http(?:s)?://[a-z0-9-]+\.(?:zendesk|zopim|futuresimple|local.futuresimple|zendesk-(?:dev|master|staging))\.com$}

    get '/app.json' do
      server_installed_json
    end

    get '/app.js' do
      serve_installed_js
    end

    enable :cross_origin

    def server_installed_json
      access_control_allow_origin
      content_type 'application/json'

      apps = []
      installations = []

      absolute_app_path = File.join(settings.root)

      manifest_json = read_json(File.join(absolute_app_path, 'manifest.json'))
      requirements_json = read_json(File.join(absolute_app_path, 'requirements.json')) || nil

      new_settings = settings.settings_helper.refresh!
      settings.parameters = new_settings if new_settings

      # add title to settings
      settings.parameters['title'] = manifest_json['name'] || 'Local App'

      apps << build_app_object(
        settings,
        manifest_json
      )

      installations << build_installation_object(
        settings,
        requirements_json
      )

      {
        apps: apps,
        installations: installations,
        installation_orders: []
      }.to_json
    end

    def build_app_object(settings, manifest)
      manifest.merge({
        asset_url_prefix: "http://localhost:#{settings.port}/",
        id: settings.app_id
      }).reject {|key| ['parameters', 'oauth'].include?(key) }
    end

    def build_installation_object(settings, requirements)
      {
        app_id: settings.app_id,
        name: settings.parameters['title'],
        collapsible: true,
        enabled: true,
        id: settings.app_id,
        plan: { name: settings.plan },
        requirements: requirements,
        settings: settings.parameters,
        updated_at: Time.now.iso8601
      }
    end

    def read_json(path, parser_opts = {})
      file = File.read(path) if File.exists?(path)
      JSON.parse(file, parser_opts) unless file.nil?
    end

    def serve_installed_js
      access_control_allow_origin
      content_type 'text/javascript'

      new_settings = settings.settings_helper.refresh!
      settings.parameters = new_settings if new_settings

      package = ZendeskAppsSupport::Package.new(settings.root, false)
      app_name = package.manifest.name || 'Local App'
      installation = ZendeskAppsSupport::Installation.new(
        id: settings.app_id,
        app_id: settings.app_id,
        app_name: app_name,
        enabled: true,
        requirements: package.requirements_json,
        collapsible: true,
        settings: settings.parameters.merge(title: app_name),
        updated_at: Time.now.iso8601,
        created_at: Time.now.iso8601,
        plan: { name: settings.plan }
      )

      app_js = package.compile(
        app_id: settings.app_id,
        app_name: app_name,
        assets_dir: "http://localhost:#{settings.port}/",
        locale: params['locale']
      )

      ZendeskAppsSupport::Installed.new([app_js], [installation]).compile
    end

    def send_file(*args)
      # does the request look like a request from the host product for the generated
      # installed.js file? If so, send that. Otherwise send the static file in the
      # app's public_folder (./assets).
      if request.env['PATH_INFO'] == '/app.js' && params.key?('locale') && params.key?('subdomain')
        serve_installed_js
      else
        access_control_allow_origin
        super(*args)
      end
    end

    def request_from_zendesk?
      request.env['HTTP_ORIGIN'] =~ ZENDESK_DOMAINS_REGEX
    end

    # This is for any preflight request
    # It reads 'Access-Control-Request-Headers' to set 'Access-Control-Allow-Headers'
    # And also sets 'Access-Control-Allow-Origin' header
    options '*' do
      access_control_allow_origin
      if request_from_zendesk?
        headers 'Access-Control-Allow-Headers' => request.env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']
      end
    end

    # This sets the 'Access-Control-Allow-Origin' header for requests coming from zendesk
    def access_control_allow_origin
      headers 'Access-Control-Allow-Origin' => request.env['HTTP_ORIGIN'] if request_from_zendesk?
    end
  end
end

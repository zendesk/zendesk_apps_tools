require 'sinatra/base'
require 'sinatra/cross_origin'
require 'zendesk_apps_support/package'

module ZendeskAppsTools
  class Server < Sinatra::Base
    set :protection, :except => :frame_options
    last_mtime = Time.new(0)
    ZENDESK_DOMAINS_REGEX = /^http(?:s)?:\/\/[a-z0-9-]+\.(?:zendesk|zopim|zd-(?:dev|master|staging))\.com$/

    get '/app.js' do
      access_control_allow_origin
      content_type 'text/javascript'

      if new_settings = settings.settings_helper.refresh!
        settings.parameters = new_settings
      end

      package = ZendeskAppsSupport::Package.new(settings.root, false)
      app_name = ENV.fetch('ZAT_APP_NAME', 'Local App')
      installation = ZendeskAppsSupport::Installation.new(
        id: settings.app_id,
        app_id: settings.app_id,
        app_name: app_name,
        enabled: true,
        requirements: package.requirements_json,
        settings: settings.parameters.merge(title: app_name),
        updated_at: Time.now.iso8601,
        created_at: Time.now.iso8601
      )

      app_js = package.compile_js(
        app_id: settings.app_id,
        app_name: app_name,
        assets_dir: "http://localhost:#{settings.port}/",
        locale: params['locale']
      )

      ZendeskAppsSupport::Installed.new([app_js], [installation]).compile_js
    end

    enable :cross_origin

    # This is for any preflight request
    # It reads 'Access-Control-Request-Headers' to set 'Access-Control-Allow-Headers'
    # And also sets 'Access-Control-Allow-Origin' header
    options "*" do
      access_control_allow_origin
      headers 'Access-Control-Allow-Headers' => request.env['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] if request.env['HTTP_ORIGIN'] =~ ZENDESK_DOMAINS_REGEX
    end

    # This sets the 'Access-Control-Allow-Origin' header for requests coming from zendesk
    def access_control_allow_origin
      origin = request.env['HTTP_ORIGIN']
      headers 'Access-Control-Allow-Origin' => origin if origin =~ ZENDESK_DOMAINS_REGEX
    end
  end
end

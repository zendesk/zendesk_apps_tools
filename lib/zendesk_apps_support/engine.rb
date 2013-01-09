if Object.const_defined?(:Rails) && Rails.const_defined?(:Engine)

  module ZendeskAppsSupport

    class Engine < Rails::Engine
      engine_name 'zendesk_apps_support'
    end

  end

end

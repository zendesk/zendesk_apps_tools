require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/api_connection'
require 'zendesk_apps_tools/deploy'
require 'zendesk_apps_tools/directory'
require 'zendesk_apps_tools/package_helper'
require 'zendesk_apps_tools/translate'
require 'zendesk_apps_tools/bump'

module ZendeskAppsTools
  module CommandHelpers
    include ZendeskAppsTools::Common
    include ZendeskAppsTools::APIConnection
    include ZendeskAppsTools::Deploy
    include ZendeskAppsTools::Directory
    include ZendeskAppsTools::PackageHelper

    def self.included(base)
      base.extend(ClassMethods)
    end

    def cache
      @cache ||= begin
        require 'zendesk_apps_tools/cache'
        Cache.new(options)
      end
    end
  end
end

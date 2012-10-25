module ZendeskAppsTools
  autoload :Command,    'zendesk_apps_tools/command'
  autoload :ZamFile,    'zendesk_apps_tools/zam_file'
  autoload :Connection, 'zendesk_apps_tools/connection'
  autoload :Package,    'zendesk_apps_tools/package'

  module Validations
    autoload :Manifest, 'zendesk_apps_tools/validations/manifest'
  end
end


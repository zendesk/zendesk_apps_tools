module ZendeskAppsTools
  autoload :AppFile,    'zendesk_apps_tools/app_file'
  autoload :AppHash,    'zendesk_apps_tools/app_hash'
  autoload :Command,    'zendesk_apps_tools/command'
  autoload :Config,     'zendesk_apps_tools/config'
  autoload :Connection, 'zendesk_apps_tools/connection'
  autoload :I18n,       'zendesk_apps_tools/i18n'
  autoload :Package,    'zendesk_apps_tools/package'

  module Validations
    autoload :ValidationError,       'zendesk_apps_tools/validations/validation_error'
    autoload :Manifest,              'zendesk_apps_tools/validations/manifest'
    autoload :Source,                'zendesk_apps_tools/validations/source'
    autoload :Translations,          'zendesk_apps_tools/validations/translations'
    autoload :Templates,             'zendesk_apps_tools/validations/templates'
    autoload :JSHintValidationError, 'zendesk_apps_tools/validations/validation_error'
  end
end


module ZendeskAppsSupport
  autoload :AppFile,    'zendesk_apps_support/app_file'
  autoload :AppHash,    'zendesk_apps_support/app_hash'
  autoload :Config,     'zendesk_apps_support/config'
  autoload :Connection, 'zendesk_apps_support/connection'
  autoload :I18n,       'zendesk_apps_support/i18n'
  autoload :Package,    'zendesk_apps_support/package'

  module Validations
    autoload :ValidationError,       'zendesk_apps_support/validations/validation_error'
    autoload :Manifest,              'zendesk_apps_support/validations/manifest'
    autoload :Source,                'zendesk_apps_support/validations/source'
    autoload :Translations,          'zendesk_apps_support/validations/translations'
    autoload :Templates,             'zendesk_apps_support/validations/templates'
    autoload :JSHintValidationError, 'zendesk_apps_support/validations/validation_error'
  end
end


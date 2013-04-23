module ZendeskAppsSupport

  require 'zendesk_apps_support/sass_functions'
  require 'zendesk_apps_support/engine'

  autoload :AppFile,    'zendesk_apps_support/app_file'
  autoload :I18n,       'zendesk_apps_support/i18n'
  autoload :Package,    'zendesk_apps_support/package'
  autoload :AppVersion,    'zendesk_apps_support/app_version'
  autoload :StylesheetCompiler,    'zendesk_apps_support/stylesheet_compiler'

  module Validations
    autoload :ValidationError,       'zendesk_apps_support/validations/validation_error'
    autoload :Manifest,              'zendesk_apps_support/validations/manifest'
    autoload :Source,                'zendesk_apps_support/validations/source'
    autoload :Templates,             'zendesk_apps_support/validations/templates'
    autoload :Translations,          'zendesk_apps_support/validations/translations'
    autoload :JSHintValidationError, 'zendesk_apps_support/validations/validation_error'
    autoload :Stylesheets,           'zendesk_apps_support/validations/stylesheets'
  end
end

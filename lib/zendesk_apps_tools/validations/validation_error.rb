module ZendeskAppsTools
  module Validations

    class ValidationError
      class << self
        attr_accessor :i18n_key_prefix

        def i18n
          @i18n ||= begin
            require 'i18n'
            ::I18n.load_path += locale_files
            ::I18n
          end
        end

        private

        def locale_files
          Dir[ File.expand_path('../../../../config/locales/*.yml', __FILE__) ]
        end
      end

      self.i18n_key_prefix = 'txt.apps.admin.error.app_build.'

      attr_reader :key, :data

      def initialize(key, data = nil)
        @key, @data = key, data || {}
      end

      def to_s
        self.class.i18n.t("#{self.class.i18n_key_prefix}#{key}", data)
      end
    end

  end
end

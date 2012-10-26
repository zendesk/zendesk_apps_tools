module ZendeskAppsTools
  module Validations

    class ValidationError
      attr_reader :key, :data

      def initialize(key, data = nil)
        @key, @data = key, data || {}
      end

      def to_s
        ZendeskAppsTools::I18n.t(key.to_s, data)
      end
    end

  end
end

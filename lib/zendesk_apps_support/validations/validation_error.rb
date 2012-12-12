module ZendeskAppsSupport
  module Validations

    class ValidationError
      attr_reader :key, :data

      def initialize(key, data = nil)
        @key, @data = key, data || {}
      end

      def to_s
        ZendeskAppsSupport::I18n.t("errors.#{key}", data)
      end
    end

    class JSHintValidationError < ValidationError
      attr_reader :filename, :jshint_errors

      def initialize(filename, jshint_errors)
        errors = jshint_errors.compact.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('')
        @filename = filename, @jshint_errors = jshint_errors
        super(:jshint_errors, {
          :file => filename,
          :errors => errors,
          :count => jshint_errors.length
        })
      end
    end
  end
end

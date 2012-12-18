require 'multi_json'

module ZendeskAppsSupport
  module Validations

    class ValidationError
      KEY_PREFIX = 'txt.apps.admin.error.app_build.'.freeze

      class DeserializationError < StandardError
        def initialize(json)
          super "Cannot deserialize ValidationError from #{json}"
        end
      end

      class << self

        # Turn a JSON string into a ValidationError.
        def from_json(json)
          hash = MultiJson.decode(json)
          raise DeserializationError.new(json) unless hash.is_a?(Hash)
          klass = constantize(hash['class'])
          raise DeserializationError.new(json) unless klass <= self
          klass.vivify(hash)
        rescue MultiJson::DecodeError, NameError
          raise DeserializationError.new(json)
        end

        # Turn a Hash into a ValidationError. Used within from_json.
        def vivify(hash)
          new(hash['key'], hash['data'])
        end

        private

        def constantize(klass)
          klass.split('::').inject(Object) { |klass, part| klass = klass.const_get(part) }
        end
      end

      attr_reader :key, :data

      def initialize(key, data = nil)
        @key, @data = key, data || {}
      end

      def to_s
        ZendeskAppsSupport::I18n.t("#{KEY_PREFIX}#{key}", data)
      end

      def to_json
        MultiJson.encode(as_json)
      end

      def as_json
        {
          'class' => self.class.to_s,
          'key'   => key,
          'data'  => data
        }
      end
    end

    class JSHintValidationError < ValidationError
      attr_reader :filename, :jshint_errors

      def self.vivify(hash)
        new(hash['filename'], hash['jshint_errors'])
      end

      def initialize(filename, jshint_errors)
        errors = jshint_errors.compact.map { |err| "\n  L#{err['line']}: #{err['reason']}" }.join('')
        @filename = filename, @jshint_errors = jshint_errors
        super(:jshint_errors, {
          :file => filename,
          :errors => errors,
          :count => jshint_errors.length
        })
      end

      def as_json
        {
          'class' => self.class.to_s,
          'filename' => filename,
          'jshint_errors' => jshint_errors
        }
      end
    end
  end
end

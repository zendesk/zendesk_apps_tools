module ZendeskAppsSupport
  module BuildTranslation

    I18N_TITLE_KEY = 'title'
    I18N_VALUE_KEY = 'value'
    I18N_KEYS      = [I18N_TITLE_KEY, I18N_VALUE_KEY]

    def to_flattened_namespaced_hash(hash, target_key = nil, prefix = nil)
      hash.inject({}) do |result, (key, value)|
        key = [prefix, key].compact.join('.')
        if value.kind_of?(Hash)
          if target_key && is_translation_hash?(value)
            result[key] = value[target_key]
          else
            result.update(to_flattened_namespaced_hash(value, target_key, key))
          end
        else
          result[key] = value
        end
        result
      end
    end

    def remove_zendesk_keys(scope, translations = {})

      scope.each_key do |key|
        context = scope[key]

        if context.is_a?(Hash)

          if is_translation_hash?(context)
            translations[key] = context[I18N_VALUE_KEY]
          else
            translations[key] ||= {}
            translations[key] = remove_zendesk_keys(context, translations[key])
          end

        else
          translations[key] = context
        end
      end

      translations
    end

    private

    def is_translation_hash?(hash)
      hash.keys.sort == I18N_KEYS
    end

  end
end

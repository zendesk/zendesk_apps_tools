module ZendeskAppsTools
  module Cache
    CACHE_FILE_NAME = '.zat'

    def save_cache(hash)
      return if options[:zipfile]

      @cache = File.exist?(cache_path) ? JSON.parse(File.read(@cache_path)).update(hash) : hash
      File.open(@cache_path, 'w') { |f| f.write JSON.pretty_generate(@cache) }
    end

    def fetch_cache(key)
      @cache ||= File.exist?(cache_path) ? JSON.parse(File.read(@cache_path)) : {}
      @cache[key] if @cache
    end

    def clear_cache
      File.delete cache_path if options[:clean] && File.exist?(cache_path)
    end

    def cache_path
      @cache_path ||= File.join options[:path], CACHE_FILE_NAME
    end
  end
end

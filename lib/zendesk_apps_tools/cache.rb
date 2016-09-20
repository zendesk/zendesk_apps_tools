# frozen_string_literal: true
require 'json'

module ZendeskAppsTools
  class Cache
    LOCAL_CACHE_FILE_NAME = '.zat'
    GLOBAL_CACHE_FILE_NAME = File.join(Dir.home, '.zat').freeze

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def save(hash)
      return if options[:zipfile]

      @cache = File.exist?(cache_path) ? JSON.parse(File.read(@cache_path)).update(hash) : hash
      File.open(@cache_path, 'w') { |f| f.write JSON.pretty_generate(@cache) }
    end

    def fetch(key)
      @cache ||= File.exist?(cache_path) ? JSON.parse(File.read(@cache_path)) : {}
      @cache[key] if @cache
    end

    def clear
      File.delete cache_path if options[:clean] && File.exist?(cache_path)
    end

    private

    def cache_path
      @cache_path ||= begin
        cache_file_name = LOCAL_CACHE_FILE_NAME
        File.join options[:path], cache_file_name
      end
    end
  end
end

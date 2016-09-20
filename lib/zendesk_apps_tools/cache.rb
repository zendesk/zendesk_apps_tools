# frozen_string_literal: true
require 'json'

module ZendeskAppsTools
  class Cache
    CACHE_FILE_NAME = '.zat'

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def save(hash)
      return if options[:zipfile]

      local_cache.update(hash)
      File.open(local_cache_path, 'w') { |f| f.write JSON.pretty_generate(local_cache) }
    end

    def fetch(key, subdomain = nil)
      # drop the default_proc and replace with Hash#dig if older Ruby versions are unsupported
      local_cache[key] || global_cache[subdomain][key] || global_cache['default'][key]
    end

    def clear
      File.delete local_cache_path if options[:clean] && File.exist?(local_cache_path)
    end

    private

    def local_cache
      @local_cache ||= File.exist?(local_cache_path) ? JSON.parse(File.read(local_cache_path)) : {}
    end

    def global_cache
      @global_cache ||= begin
        if File.exist?(global_cache_path)
          JSON.parse(File.read(global_cache_path)).tap do |cache|
            cache.default_proc = proc do |_hash, _key|
              {}
            end
          end
        else
          Hash.new({})
        end
      end
    end

    def global_cache_path
      @global_cache_path ||= File.join(Dir.home, CACHE_FILE_NAME)
    end

    def local_cache_path
      @local_cache_path ||= File.join(options[:path], CACHE_FILE_NAME)
    end
  end
end

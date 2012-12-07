require 'sass'

module ZendeskAppsSupport
  class StylesheetCompiler

    def initialize(source, app_id, url_prefix)
      @source, @app_id, @url_prefix = source, app_id, url_prefix
    end

    def compile
      Sass::Engine.new(wrapped_source, :syntax => :scss, :app_asset_url_builder => self).render
    end

    def app_asset_url(name)
      "#{@url_prefix}/#{name}"
    end

    private

    def wrapped_source
      ".app-#{@app_id} {#{@source}}"
    end

  end
end

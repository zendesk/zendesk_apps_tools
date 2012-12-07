require 'sass'

class ZendeskAppsTools::StylesheetCompiler

  def initialize(source, app_id)
    @source, @app_id = source, app_id
  end

  def compile
    Sass::Engine.new(wrapped_source, :syntax => :scss, :app_asset_url_builder => self).render
  end

  def app_asset_url(name)
    "http://localhost:#{ZendeskAppsTools::Command.port}/#{name}"
  end

  private

  def wrapped_source
    ".app-#{@app_id} {#{@source}}"
  end

end

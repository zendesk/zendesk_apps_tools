require 'sass'

module Sass::Script::Functions

  module AppAssetUrl
    def app_asset_url(name)
      assert_type name, :String
      result = %Q{url("#{app_asset_url_helper(name)}")}
      Sass::Script::String.new(result)
    end

    private

    def app_asset_url_helper(name)
      url_builder = options[:app_asset_url_builder]
      url_builder.app_asset_url(name.value)
    end
  end

  include AppAssetUrl

end

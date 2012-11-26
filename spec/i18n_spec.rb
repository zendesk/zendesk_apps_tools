require 'zendesk_apps_support'

describe ZendeskAppsSupport::I18n do

  it 'should translate error messages' do
    ZendeskAppsSupport::I18n.t("errors.missing_manifest").should == 'Could not find manifest.json'
  end
end
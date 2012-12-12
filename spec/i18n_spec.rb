require 'zendesk_apps_support'
require 'pathname'

describe ZendeskAppsSupport::I18n do

  it 'should translate error messages' do
    key_prefix = ZendeskAppsSupport::Validations::ValidationError::KEY_PREFIX
    ZendeskAppsSupport::I18n.t("#{key_prefix}.missing_manifest").should == 'Could not find manifest.json'
  end

end

describe 'translations' do

  it 'should be up-to-date' do
    project_root = Pathname.new(File.expand_path('../../', __FILE__))
    zendesk_version  = project_root.join('config/locales/en.zendesk.yml')
    standard_version = project_root.join('config/locales/en.yml')
    File.mtime(standard_version).should be >= File.mtime(zendesk_version)
  end

end

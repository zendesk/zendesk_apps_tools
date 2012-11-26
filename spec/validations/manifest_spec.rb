require 'zendesk_apps_support'

describe ZendeskAppsSupport::Validations::Manifest do

  it 'should have an error when manifest.json is missing' do
    files = [mock('AppFile', :relative_path => 'abc.json')]
    package = mock('Package', :files => files)
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    errors.first().to_s.should eql 'Could not find manifest.json'
  end

  it 'should have an error when required field is missing' do
    manifest = mock('AppFile', :relative_path => 'manifest.json', :read => "{}")
    package = mock('Package', :files => [manifest])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    errors.first().to_s.should eql 'Missing required fields in manifest: author, defaultLocale, location, frameworkVersion'
  end

  it 'should have an error when manifest is not a valid json' do
    manifest = mock('AppFile', :relative_path => 'manifest.json', :read => "{")
    package = mock('Package', :files => [manifest])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    errors.first().to_s.should eql 'manifest is not proper JSON. A JSON text must at least contain two octets!'
  end
end
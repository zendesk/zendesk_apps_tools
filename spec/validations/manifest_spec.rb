require 'zendesk_apps_support'
require 'json'

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

  it 'should have an error when the defaultLocale is invalid' do
    manifest = { 'defaultLocale' => 'pt-BR' }
    manifest_file = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(manifest))
    package = mock('Package', :files => [manifest_file])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    locale_error = errors.find { |e| e.to_s =~ /default locale/ }
    locale_error.should_not be_nil
  end

  it 'should have an error when the location is invalid' do
    manifest = { 'location' => ['ticket_sidebar', 'a_invalid_location'] }
    manifest_file = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(manifest))
    package = mock('Package', :files => [manifest_file])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    locations_error = errors.find { |e| e.to_s =~ /invalid location/ }
    locations_error.should_not be_nil
  end

  it 'should have an error when manifest is not a valid json' do
    manifest = mock('AppFile', :relative_path => 'manifest.json', :read => "}")
    package = mock('Package', :files => [manifest])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    errors.first().to_s.should =~ /^manifest is not proper JSON/
  end
end
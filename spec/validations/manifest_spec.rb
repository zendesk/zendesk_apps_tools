require 'zendesk_apps_support'
require 'json'

describe ZendeskAppsSupport::Validations::Manifest do

  def default_required_params(overrides = {})
    valid_fields = ZendeskAppsSupport::Validations::Manifest::REQUIRED_MANIFEST_FIELDS.inject({}) do |fields, name|
      fields[name] = name
      fields
    end

    valid_fields.merge(overrides)
  end

  def create_package(parameter_hash)
    params = default_required_params(parameter_hash)
    manifest = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(params))
    mock('Package', :files => [manifest])
  end

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

  it 'should have an error when the translation file is missing for the defaultLocale' do
    manifest = { 'defaultLocale' => 'pt' }
    manifest_file = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(manifest))
    translation_files = mock('AppFile', :relative_path => 'translations/en.json')
    package = mock('Package', :files => [manifest_file], :translation_files => [translation_files])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    locale_error = errors.find { |e| e.to_s =~ /Missing translation file/ }
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

  it 'should have an error when the version is not supported' do
    manifest = { 'frameworkVersion' => '0.7' }
    manifest_file = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(manifest))
    package = mock('Package', :files => [manifest_file])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    version_error = errors.find { |e| e.to_s =~ /not a valid framework version/ }
    version_error.should_not be_nil
  end

  it 'should have an error when a hidden parameter is set to required' do
    manifest = {
      'parameters' => [
        'name'     => 'a parameter',
        'type'     => 'hidden',
        'required' => true
      ]
    }

    manifest_file = mock('AppFile', :relative_path => 'manifest.json', :read => JSON.dump(manifest))
    package = mock('Package', :files => [manifest_file])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    hidden_params_error = errors.find { |e| e.to_s =~ /set to hidden and cannot be required/ }
    hidden_params_error.should_not be_nil
  end

  it 'should have an error when manifest is not a valid json' do
    manifest = mock('AppFile', :relative_path => 'manifest.json', :read => "}")
    package = mock('Package', :files => [manifest])
    errors = ZendeskAppsSupport::Validations::Manifest.call(package)

    errors.first().to_s.should =~ /^manifest is not proper JSON/
  end

  it "should have an error when required oauth fields are missing" do
    oauth_hash = {
      "oauth" => {}
    }
    errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(default_required_params.merge(oauth_hash)))
    oauth_error = errors.find { |e| e.to_s =~ /oauth field/ }
    oauth_error.to_s.should == "Missing required oauth fields in manifest: client_id, client_secret, authorize_uri, access_token_uri"
  end

  context 'with invalid parameters' do

    before do
      ZendeskAppsSupport::Validations::Manifest.stub(:default_locale_error)
      ZendeskAppsSupport::Validations::Manifest.stub(:invalid_location_error)
      ZendeskAppsSupport::Validations::Manifest.stub(:invalid_version_error)
    end

    it 'has an error when the app parameters are not an array' do
      parameter_hash = {
          'parameters' => {
              'name' => 'a parameter',
              'type' => 'text'
          }
      }

      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(parameter_hash))
      errors.map(&:to_s).should == ['App parameters must be an array.']
    end

    it "doesn't have an error with an array of app parameters" do
      parameter_hash = {
          'parameters' => [{
              'name' => 'a parameter',
              'type' => 'text'
          }]
      }

      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(parameter_hash))
      errors.should be_empty
    end

    it 'behaves when the manifest does not have parameters' do
      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(default_required_params))
      errors.should be_empty
    end

    it 'shows error when duplicate parameters are defined' do
      parameter_hash = {
        'parameters' => [
          {
            'name' => 'url',
            'type' => 'text'
          },
          {
            'name' => 'url',
            'type' => 'text'
          }
        ]
      }

      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(parameter_hash))
      errors.map(&:to_s).should == ['Duplicate app parameters defined: ["url"]']
    end

    it 'has an error when the parameter type is not valid' do
      parameter_hash = {
        'parameters' =>
        [
         {
           'name' => 'should be number',
           'type' => 'integer'
         }
        ]
      }
      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(default_required_params.merge(parameter_hash)))

      expect(errors.count).to eq 1
      expect(errors.first.to_s).to eq "integer is an invalid parameter type."
    end

    it "doesn't have an error with a correct parameter type" do
      parameter_hash = {
        'parameters' =>
        [
         {
           'name' => 'valid type',
           'type' => 'number'
         }
        ]
      }
      errors = ZendeskAppsSupport::Validations::Manifest.call(create_package(default_required_params.merge(parameter_hash)))
      expect(errors).to be_empty
    end
  end
end

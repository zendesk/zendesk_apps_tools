require 'zendesk_apps_support'

describe ZendeskAppsSupport::Validations::Source do

  it 'should have an error when app.js is missing' do
    files = [mock('AppFile', :relative_path => 'abc.js')]
    package = mock('Package', :files => files)
    errors = ZendeskAppsSupport::Validations::Source.call(package)

    errors.first().to_s.should eql 'Could not find app.js'
  end

  it 'should have a jslint error when missing semicolon' do
    source = mock('AppFile', :relative_path => 'app.js', :read => "var a = 1")
    package = mock('Package', :files => [source])
    errors = ZendeskAppsSupport::Validations::Source.call(package)

    errors.first().to_s.should eql "JSHint error in app.js: \n  L1: Missing semicolon."
  end

end
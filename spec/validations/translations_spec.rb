require 'zendesk_apps_support'
require 'json'

describe ZendeskAppsSupport::Validations::Translations do

  let(:package) { mock('Package', :files => translation_files) }
  subject { ZendeskAppsSupport::Validations::Translations.call(package) }

  context 'when there are no translation files' do
    let(:translation_files) { [] }
    it 'should be valid' do
      subject.should be_empty
    end
  end

  context 'when there is file with invalid JSON' do
    let(:translation_files) do
      [ mock('AppFile', :relative_path => 'translations/en.json', :read => '}') ]
    end

    it 'should report the error' do
      subject.length.should == 1
      subject[0].to_s.should =~ /JSON/
    end
  end

  context 'when there is file with JSON representing a non-Object' do
    let(:translation_files) do
      [ mock('AppFile', :relative_path => 'translations/en.json', :read => '"foo bar"') ]
    end

    it 'should report the error' do
      subject.length.should == 1
      subject[0].to_s.should =~ /JSON/
    end
  end

  context 'when there is a file with an invalid locale for a name' do
    let(:translation_files) do
      [ mock('AppFile', :relative_path => 'translations/en-US.json', :read => '{}') ]
    end

    it 'should report the error' do
      subject.length.should == 1
      subject[0].to_s.should =~ /locale/
    end
  end

  context 'when there is a file with a valid locale containing valid JSON' do
    let(:translation_files) do
      [ mock('AppFile', :relative_path => 'translations/en.json', :read => '{}') ]
    end

    it 'should be valid' do
      subject.length.should == 0
    end
  end
end
require 'spec_helper'
require 'translate'

describe ZendeskAppsTools::Translate do
  describe '#to_yml' do
    it 'should convert i18n formatted json to translation yml' do
      root = 'spec/fixture/i18n_app_to_yml'
      target_yml = "#{root}/translations/en.yml"
      File.delete(target_yml) if File.exist?(target_yml)
      translate = ZendeskAppsTools::Translate.new
      translate.setup_path(root)
      translate.to_yml

      File.read(target_yml).should == File.read("#{root}/translations/expected.yml")
      File.delete(target_yml) if File.exist?(target_yml)
    end
  end

  describe '#to_json' do
    it 'should convert translation yml to i18n formatted json' do
      root = 'spec/fixture/i18n_app_to_json'
      target_json = "#{root}/translations/en.json"
      File.delete(target_json) if File.exist?(target_json)
      translate = ZendeskAppsTools::Translate.new
      translate.setup_path(root)
      translate.to_json

      File.read(target_json).should == File.read("#{root}/translations/expected.json")
      File.delete(target_json) if File.exist?(target_json)
    end
  end

  describe '#nest_translations_hash' do
    it 'removes package key prefix' do
      translations = { 'txt.apps.my_app.app.description' => 'Description' }

      result = { 'app' => { 'description' => 'Description' } }

      context = ZendeskAppsTools::Translate.new
      context.nest_translations_hash(translations, 'txt.apps.my_app.').should == result
    end

    context 'with a mix of nested and unnested keys' do
      it 'returns a mixed depth hash' do
        translations = {
          'app.description' => 'This app is awesome',
          'app.parameters.awesomeness.label' => 'Awesomeness level',
          'global.error.title'   => 'An error occurred',
          'global.error.message' => 'Please try the previous action again.',
          'global.loading'       => 'Waiting for ticket data to load...',
          'global.requesting'    => 'Requesting data from Magento...',
          'errormessage'         => 'General error' }

        result = {
          'app' => {
            'description' => 'This app is awesome',
            'parameters' => {
              'awesomeness' => { 'label' => 'Awesomeness level' } }
          },
          'global' => {
            'error' => {
              'title'   => 'An error occurred',
              'message' => 'Please try the previous action again.'
            },
            'loading'    => 'Waiting for ticket data to load...',
            'requesting' => 'Requesting data from Magento...'
          },
          'errormessage' => 'General error'
        }

        context = ZendeskAppsTools::Translate.new
        context.nest_translations_hash(translations, '').should == result
      end
    end
  end

  # This would be better as an integration test but it requires significant
  # refactoring of the cucumber setup and addition of vcr or something similar
  # This is happy day only
  describe '#update' do
    it 'fetches locales, translations and generates json files for each' do
      translate = ZendeskAppsTools::Translate.new
      translate.stub(:say)
      translate.stub(:ask).with('What is the package name for this app? (without app_)').and_return('my_app')
      translate.stub(:create_file)

      translate.should_receive(:nest_translations_hash).once.and_return({})

      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/api/v2/locales/agent.json') do
            [200, {}, JSON.dump('locales' => [{ 'url' => 'https://support.zendesk.com/api/v2/rosetta/locales/1.json',
                                                'locale' => 'en' }])]
          end
          stub.get('/api/v2/rosetta/locales/1.json?include=translations&packages=app_my_app') do
            [200, {}, JSON.dump('locale' => { 'translations' =>
                                                    { 'app.description' => 'my awesome app' } })]
          end
        end
      end

      translate.update(test)
    end
  end
end

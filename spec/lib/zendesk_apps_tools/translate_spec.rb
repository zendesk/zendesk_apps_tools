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
      begin
        translate.to_yml
        expect(File.read(target_yml)).to eq(File.read("#{root}/translations/expected.yml"))
      ensure
        File.delete(target_yml) if File.exist?(target_yml)
      end
    end
  end

  describe '#to_json' do
    it 'should convert translation yml to i18n formatted json' do
      root = 'spec/fixture/i18n_app_to_json'
      target_json = "#{root}/translations/en.json"
      File.delete(target_json) if File.exist?(target_json)
      translate = ZendeskAppsTools::Translate.new
      translate.setup_path(root)
      begin
        translate.to_json
        expect(File.read(target_json)).to eq(File.read("#{root}/translations/expected.json"))
      ensure
        File.delete(target_json) if File.exist?(target_json)
      end
    end
  end

  describe '#nest_translations_hash' do
    it 'removes package key prefix' do
      translations = { 'txt.apps.my_app.app.description' => 'Description' }

      result = { 'app' => { 'description' => 'Description' } }

      context = ZendeskAppsTools::Translate.new
      expect(context.nest_translations_hash(translations, 'txt.apps.my_app.')).to eq(result)
    end

    describe 'with a mix of nested and unnested keys' do
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
        expect(context.nest_translations_hash(translations, '')).to eq(result)
      end
    end
  end

  # This would be better as an integration test but it requires significant
  # refactoring of the cucumber setup and addition of vcr or something similar
  # This is happy day only
  describe '#update' do
    it 'fetches locales, translations and generates json files for each' do
      translate = ZendeskAppsTools::Translate.new
      allow(translate).to receive(:say)
      allow(translate).to receive(:ask).with('What is the package name for this app? (without leading app_)', default: nil).and_return('my_app')
      allow(translate).to receive(:create_file)

      expect(translate).to receive(:nest_translations_hash).once.and_return({})

      stub_request(:get, "https://support.zendesk.com/api/v2/locales/agent.json").
         to_return(:status => 200, :body => JSON.dump('locales' => [{ 'url' => 'https://support.zendesk.com/api/v2/rosetta/locales/1.json', 'locale' => 'en' }]))

      stub_request(:get, "https://support.zendesk.com/api/v2/rosetta/locales/1.json?include=translations&packages=app_my_app").
         to_return(:status => 200, :body => JSON.dump('locale' => { 'locale' => 'en', 'translations' => { 'app.description' => 'my awesome app' } }))

      translate.update()
    end
  end

  describe "#pseudotranslate" do
    it 'generates a json file for the specified locale' do
      root = 'spec/fixture/i18n_app_pseudotranslate'
      target_json = "#{root}/translations/fr.json"
      File.delete(target_json) if File.exist?(target_json)
      translate = ZendeskAppsTools::Translate.new
      translate.setup_path(root)
      begin
        translate.pseudotranslate

        expect(File.read(target_json)).to eq(File.read("#{root}/translations/expected.json"))
      ensure
        File.delete(target_json) if File.exist?(target_json)
      end
    end
  end
end

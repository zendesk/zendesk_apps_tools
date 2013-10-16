require 'spec_helper'
require 'translate'

describe ZendeskAppsTools::Translate do

  describe 'retrieving keys from a hash' do

    context 'top level' do
      it 'returns the full key and translation' do
        translation_hash = { 'profile' => 'Profile' }

        translate = ZendeskAppsTools::Translate.new
        result = translate.get_translations_for translation_hash, 'profile'

        result.should == { 'profile' => 'Profile' }
      end
    end

    context 'without nesting' do
      it 'returns the full key and translation' do

        translation_hash = {'profile' => {
                              'customer_since' => 'Customer Since',
                              'addresses'      => 'Addresses'}}

        translate = ZendeskAppsTools::Translate.new
        result = translate.get_translations_for translation_hash, 'profile'

        result.should == { 'profile.customer_since' => 'Customer Since',
                           'profile.addresses'      => 'Addresses' }
      end
    end

    context 'one nested set' do
      context 'a mix of nested and unnested keys' do
        it 'returns the full key and translation' do
          translation_hash = { 'global'=> {
            'error'=> {
              'title'   => 'An error occurred',
              'message' => 'Please try the previous action again.',
            },
            'loading'    => 'Waiting for ticket data to load...',
            'requesting' => 'Requesting data from Magento...'}}

          translate = ZendeskAppsTools::Translate.new
          result = translate.get_translations_for translation_hash, 'global'

          result.should == { 'global.error.title'   => 'An error occurred',
                             'global.error.message' => 'Please try the previous action again.',
                             'global.loading'       => 'Waiting for ticket data to load...',
                             'global.requesting'    => 'Requesting data from Magento...' }
        end
      end
    end

    context 'multi level nesting' do
      it 'returns the full key and translation' do
        translation_hash = { 'global'=> {
          'error'=> {
            'title'   => 'An error occurred',
            'message' => {
              'start' => 'Please try',
              'end'   => 'the previous action again.'
            }}}}

          translate = ZendeskAppsTools::Translate.new
          result = translate.get_translations_for translation_hash, 'global'

          result.should == {'global.error.title'         => 'An error occurred',
                            'global.error.message.start' => 'Please try',
                            'global.error.message.end'   => 'the previous action again.'}
      end
    end

  end

  describe '#nest_translations_hash' do
    it 'removes package key prefix' do
      translations = { "txt.apps.my_app.app.description" => "Description" }

      result = { "app" => { "description" => "Description" }}

      context = translate = ZendeskAppsTools::Translate.new
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
              'awesomeness' => {'label' => 'Awesomeness level'}}
          },
          'global'=> {
            'error'=> {
              'title'   => 'An error occurred',
              'message' => 'Please try the previous action again.',
          },
          'loading'    => 'Waiting for ticket data to load...',
          'requesting' => 'Requesting data from Magento...'},
          'errormessage' => 'General error'}

        context = translate = ZendeskAppsTools::Translate.new
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
      translate.stub(:ask).with("What is the package name for this app? (without app_)").and_return('my_app')
      translate.stub(:create_file)

      translate.should_receive(:nest_translations_hash).once.and_return({})

      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/api/v2/locales/agent.json') do
            [ 200, {}, JSON.dump( {"locales" => [ {'url' => 'https://support.zendesk.com/api/v2/rosetta/locales/1.json',
                                                     'locale' => 'en' } ]})]
          end
          stub.get('/api/v2/rosetta/locales/1.json?include=translations&packages=app_my_app') do
            [ 200, {}, JSON.dump( { 'locale' => { 'translations' =>
                                                    { 'app.description' => 'my awesome app' }}})]
          end
        end
      end

      translate.update(test)
    end

  end
end

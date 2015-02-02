require 'spec_helper'
require 'common'
require 'settings'

describe ZendeskAppsTools::Settings do
  before(:each) do
    @context = ZendeskAppsTools::Settings.new
    @user_input = Object.new
    @user_input.extend(ZendeskAppsTools::Common)
    @user_input.stub(:ask).and_return('') # this represents the default user input
  end

  describe '#get_settings_from_user_input' do
    it 'accepts user input with colon & slashes' do
      parameters = [
        {
          name: 'backend',
          required: true,
          default: 'https://example.com:3000'
        }
      ]

      settings = {
        'backend' => 'https://example.com:3000'
      }

      @user_input.stub(:ask).with("Enter a value for required parameter 'backend':\n").and_return('https://example.com:3000')

      @context.get_settings_from_user_input(@user_input, parameters).should == settings
    end

    it 'should use default boolean parameter' do
      parameters = [
        {
          name: 'isUrgent',
          type: 'checkbox',
          required: true,
          default: true
        }
      ]

      settings = {
        'isUrgent' => true
      }

      @user_input.stub(:ask).with("Enter a value for required parameter 'isUrgent':\n").and_return('')

      @context.get_settings_from_user_input(@user_input, parameters).should == settings
    end

    it 'prompts the user for settings' do
      parameters = [
        {
          name: 'required',
          required: true
        },
        {
          name: 'required_with_default',
          required: true,
          default: '123'
        },
        {
          name: 'not_required'
        },
        {
          name: 'not_required_with_default',
          default: '789'
        },
        {
          name: 'skipped'
        }
      ]

      settings = {
        'required'                  => 'xyz',
        'required_with_default'     => '123',
        'not_required'              => '456',
        'not_required_with_default' => '789'
      }

      @user_input.stub(:ask).with("Enter a value for required parameter 'required':\n").and_return('xyz')
      @user_input.stub(:ask).with("Enter a value for optional parameter 'not_required' or press 'Return' to skip:\n").and_return('456')

      @context.get_settings_from_user_input(@user_input, parameters).should == settings
    end
  end

  describe '#get_settings_from_file' do
    context 'when the file doesn\'t exist' do
      it 'returns nil' do
        @context.get_settings_from_file('spec/fixture/none_existing/settings.yml', []).should.nil?
      end
    end

    context 'with a JSON file' do
      it 'returns the settings' do
        parameters = [
          {
            name: 'text',
            type: 'text'
          },
          {
            name: 'number',
            type: 'text'
          },
          {
            name: 'checkbox',
            type: 'checkbox'
          },
          {
            name: 'array',
            type: 'multiline'
          },
          {
            name: 'object',
            type: 'multiline'
          }
        ]

        settings = {
          'text' => 'text',
          'number' => 1,
          'checkbox' => true,
          'array' => "[\"test1\"]",
          'object' => "{\"test1\":\"value\"}"
        }

        @context.get_settings_from_file('spec/fixture/config/settings.json', parameters).should == settings
      end
    end

    context 'with a YAML file' do
      it 'returns the settings 1 level deep when the file exist' do
        parameters = [
          {
            name: 'text',
            type: 'text'
          },
          {
            name: 'number',
            type: 'text'
          },
          {
            name: 'checkbox',
            type: 'checkbox'
          },
          {
            name: 'array',
            type: 'multiline'
          },
          {
            name: 'object',
            type: 'multiline'
          }
        ]

        settings = {
          'text' => 'text',
          'number' => 1,
          'checkbox' => true,
          'array' => "[\"test1\"]",
          'object' => "{\"test1\":\"value\"}"
        }

        @context.get_settings_from_file('spec/fixture/config/settings.yml', parameters).should == settings
      end

      it 'returns the default because you forgot to specifiy a required field with a default' do
        parameters = [
          {
            name: 'required',
            type: 'text',
            required: true,
            default: 'ok'
          }
        ]

        settings = {
          'required' => 'ok'
        }

        @context.get_settings_from_file('spec/fixture/config/settings.yml', parameters).should == settings
      end

      it 'returns nil because you forgot to specifiy a required field without a default' do
        parameters = [
          {
            name: 'required',
            type: 'text',
            required: true
          }
        ]

        @context.get_settings_from_file('spec/fixture/config/settings.yml', parameters).should.nil?
      end
    end
  end
end

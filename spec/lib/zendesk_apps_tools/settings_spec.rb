require 'spec_helper'
require 'common'
require 'settings'

describe ZendeskAppsTools::Settings do
  before(:each) do
    @user_input = Object.new
    allow(@user_input).to receive(:ask) do |_p, thor_opts| # this represents the default user input
      thor_opts && thor_opts[:default] || ''
    end
    allow(@user_input).to receive(:say)
    allow(@user_input).to receive(:options).and_return({})
    @user_input.extend(ZendeskAppsTools::Common)
    @context = ZendeskAppsTools::Settings.new(@user_input)
  end

  describe '#get_settings_from_user_input' do
    it 'accepts user input with colon & slashes' do
      parameters = [
        {
          'name' => 'backend',
          'required' => true,
          'default' => 'https://example.com:3000'
        }
      ]

      settings = {
        'backend' => 'https://example.com:3000'
      }

      allow(@user_input).to receive(:ask).with("Enter a value for required parameter 'backend':\n").and_return('https://example.com:3000')
      expect(@context.get_settings_from_user_input(parameters)).to eq(settings)
    end

    it 'should use default boolean parameter' do
      parameters = [
        {
          'name' => 'isUrgent',
          'type' => 'checkbox',
          'required' => true,
          'default' => true
        }
      ]

      settings = {
        'isUrgent' => true
      }

      expect(@context.get_settings_from_user_input(parameters)).to eq(settings)
    end

    it 'prompts the user for settings' do
      parameters = [
        {
          'name' => 'required',
          'required' => true
        },
        {
          'name' => 'required_with_default',
          'required' => true,
          'default' => '123'
        },
        {
          'name' => 'not_required'
        },
        {
          'name' => 'not_required_with_default',
          'default' => '789'
        },
        {
          'name' => 'skipped'
        }
      ]

      settings = {
        'required'                  => 'xyz',
        'required_with_default'     => '123',
        'not_required'              => '456',
        'not_required_with_default' => '789'
      }

      allow(@user_input).to receive(:ask).with("Enter a value for required parameter 'required':\n", default: nil).and_return('xyz')
      allow(@user_input).to receive(:ask).with("Enter a value for optional parameter 'not_required' or press 'Return' to skip:\n", default: nil).and_return('456')
      expect(@context.get_settings_from_user_input(parameters)).to eq(settings)
    end
  end

  describe '#get_settings_from_file' do
    context 'when the file doesn\'t exist' do
      it 'returns nil' do
        expect(@context.get_settings_from_file('spec/fixture/none_existing/settings.yml', [])).to be_nil
      end
    end

    context 'with a JSON file' do
      it 'returns the settings' do
        parameters = [
          {
            'name' => 'text',
            'type' => 'text'
          },
          {
            'name' => 'number',
            'type' => 'text'
          },
          {
            'name' => 'checkbox',
            'type' => 'checkbox'
          },
          {
            'name' => 'array',
            'type' => 'multiline'
          },
          {
            'name' => 'object',
            'type' => 'multiline'
          }
        ]

        settings = {
          'text' => 'text',
          'number' => 1,
          'checkbox' => true,
          'array' => "[\"test1\"]",
          'object' => "{\"test1\":\"value\"}"
        }

        expect(@context.get_settings_from_file('spec/fixture/config/settings.json', parameters)).to eq(settings)
      end
    end

    context 'with a YAML file' do
      it 'returns the settings 1 level deep when the file exist' do
        parameters = [
          {
            'name' => 'text',
            'type' => 'text'
          },
          {
            'name' => 'number',
            'type' => 'text'
          },
          {
            'name' => 'checkbox',
            'type' => 'checkbox'
          },
          {
            'name' => 'array',
            'type' => 'multiline'
          },
          {
            'name' => 'object',
            'type' => 'multiline'
          }
        ]

        settings = {
          'text' => 'text',
          'number' => 1,
          'checkbox' => true,
          'array' => "[\"test1\"]",
          'object' => "{\"test1\":\"value\"}"
        }

        expect(@context.get_settings_from_file('spec/fixture/config/settings.yml', parameters)).to eq(settings)
      end

      it 'returns the default because you forgot to specify a required field with a default' do
        parameters = [
          {
            'name' => 'required',
            'type' => 'text',
            'required' => true,
            'default' => 'ok'
          }
        ]

        settings = {
          'required' => 'ok'
        }

        expect(@context.get_settings_from_file('spec/fixture/config/settings.yml', parameters)).to eq(settings)
      end

      it 'returns nil because you forgot to specifiy a required field without a default' do
        parameters = [
          {
            'name' => 'required',
            'type' => 'text',
            'required' => true
          }
        ]

        expect(@context.get_settings_from_file('spec/fixture/config/settings.yml', parameters)).to be_nil
      end

      it 'returns false if specified even if the default is true' do
        parameters = [
          {
            'name' => 'falsey',
            'type' => 'checkbox',
            'default' => true
          }
        ]

        expect(@context.get_settings_from_file('spec/fixture/config/settings.yml', parameters)).to eq 'falsey' => false
      end
    end
  end

  describe '#refresh!' do
    before do
      @context.get_settings_from_file('test path', [])
    end
    it 'does not crash' do
      @context.refresh!
    end

    context 'when the file exists' do
      before do
        allow(File).to receive(:file?).and_return(true)
        allow(File).to receive(:stat).and_return(double('File::Stat', mtime: Time.now))
      end

      it 'works' do
        expect(@context).to receive :get_settings_from_file
        @context.refresh!
      end
    end
  end
end

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

  describe '#get_settings_from' do
    it 'accepts user input with colon & slashes' do
      parameters = [
        {
          :name     => "backend",
          :required => true,
          :default  => "https://example.com:3000"
        }
      ]

      settings = {
        "backend" => "https://example.com:3000"
      }

      @user_input.stub(:ask).with("Enter a value for required parameter 'backend':\n").and_return("https://example.com:3000")

      result = @context.get_settings_from(@user_input, parameters).should == settings
    end

    it 'prompts the user for settings' do
      parameters = [
        {
          :name     => "required",
          :required => true
        },
        {
          :name     => "required_with_default",
          :required => true,
          :default  => "123"
        },
        {
          :name     => "not_required",
        },
        {
          :name     => "not_required_with_default",
          :default  => "789"
        },
        {
          :name     => "skipped",
        }
      ]

      settings = {
        "required"                  => "xyz",
        "required_with_default"     => "123",
        "not_required"              => "456",
        "not_required_with_default" => "789"
      }

      @user_input.stub(:ask).with("Enter a value for required parameter 'required':\n").and_return('xyz')
      @user_input.stub(:ask).with("Enter a value for optional parameter 'not_required' or press 'Return' to skip:\n").and_return('456')

      result = @context.get_settings_from(@user_input, parameters).should == settings
    end
  end

end

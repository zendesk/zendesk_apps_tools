require 'spec_helper'
require 'common'
require 'settings'

describe ZendeskAppsTools::Settings do

  before(:each) do
    @interface = Object.new
    @interface.extend(ZendeskAppsTools::Common)
  end

  describe '#settings_for_parameters' do
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

      context = ZendeskAppsTools::Settings.new(@interface)
      @interface.stub(:ask).and_return('') # this represents the default user input
      @interface.stub(:ask).with("Enter a value for required parameter 'required':\n").and_return('xyz')
      @interface.stub(:ask).with("Enter a value for optional parameter 'not_required' or press 'Return' to skip:\n").and_return('456')

      result = context.settings_for_parameters(parameters).should == settings
    end
  end

end

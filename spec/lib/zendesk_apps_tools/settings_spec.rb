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
          :name => "setting1",
          :required => true,
          :default => "123"
        },
        {
          :name => "setting2",
          :required => "xyz"
        },
        {
          :name => "setting3",
          :default => "456"
        },
        {
          :name => "setting4",
        },
        {
          :name => "setting5",
        }
      ]

      settings = {
        "setting1" => "123",
        "setting2" => "xyz",
        "setting3" => "456",
        "setting5" => "789"
      }

      context = ZendeskAppsTools::Settings.new(@interface)
      @interface.stub(:ask).and_return('')
      @interface.stub(:ask).with("Enter a value for required parameter 'setting2':\n").and_return('xyz')
      @interface.stub(:ask).with("Enter a value for optional parameter 'setting5' or press 'Return' to skip:\n").and_return('789')

      result = context.settings_for_parameters(parameters).should == settings
    end
  end

end

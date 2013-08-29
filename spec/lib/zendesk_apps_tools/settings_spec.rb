require 'spec_helper'
require 'settings'

describe ZendeskAppsTools::Settings do

  before(:each) do
    @context = Object.new
    @context.extend(ZendeskAppsTools::Settings)
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
          :default => "456"
        },
        {
          :name => "setting3",
        }
      ]

      settings = {
        "setting1" => "123",
        "setting2" => "456"
      }


      @context.stub(:ask).and_return('')
      result = @context.settings_for_parameters(parameters)

      result.should == settings
    end
  end

end

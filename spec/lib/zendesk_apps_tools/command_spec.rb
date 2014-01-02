require 'spec_helper'
require 'command'

describe ZendeskAppsTools::Command do

  before do
    @command = ZendeskAppsTools::Command.new
  end

  it 'can be instantiated' do
    @command.should_not == nil
  end

  describe '#upload' do

    it 'returns the id of the successfully uploaded app zipfile' do
      data = double('data')
      Faraday::UploadIO.stub(:new) { data }

      conn = double('conn')
      @command.stub(:get_connection) { conn }

      @command.stub(:package)

      payload = { :uploaded_data => data }
      response = double('response', :body => '{ "id": 123 }')
      conn.should_receive(:post).with('/api/v2/apps/uploads.json', payload).and_return(response)

      @command.send(:upload, 'hell').should == 123
    end

  end

end

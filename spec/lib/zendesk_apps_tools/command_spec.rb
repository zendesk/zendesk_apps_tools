require 'spec_helper'
require 'command'

describe ZendeskAppsTools::Command do

  PREFIX = 'https://username:password@subdomain.zendesk.com'

  before do
    @command = ZendeskAppsTools::Command.new
    @command.instance_variable_set(:@username, 'username')
    @command.instance_variable_set(:@password, 'password')
    @command.instance_variable_set(:@subdomain, 'subdomain')
    @command.instance_variable_set(:@app_id, '123')

    @command.stub(:get_cache)
    @command.stub(:set_cache)
    @command.stub(:clear_cache)
    @command.stub(:options) { { :clean => false, :path => './' } }
    # @command.stub(:set_cache)
  end

  describe '#upload' do
    context 'when no zipfile is given' do
      it 'uploads the zipfile and returns an upload id' do
        @command.stub(:package)
        @command.stub(:options) { { :zipfile => nil } }
        Faraday::UploadIO.stub(:new)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .to_return(:body => '{ "id": 123 }')

        @command.upload('nah').should == 123
      end
    end

    context 'when zipfile is given' do
      it 'uploads the zipfile and returns an upload id' do
        @command.stub(:options) { { :zipfile => 'app.zip' } }
        Faraday::UploadIO.should_receive(:new).with('app.zip', 'application/zip').and_return(nil)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .to_return(:body => '{ "id": 123 }')

        @command.upload('nah').should == 123
      end
    end
  end

  describe '#create' do
    context 'when no zipfile is given' do
      it 'uploads a file and posts build api' do
        @command.should_receive(:upload).and_return(123)
        @command.stub(:check_status)
        File.should_receive(:read) { '{ "name": "abc" }' }

        stub_request(:post, PREFIX + '/api/v2/apps.json')
          .with(:body => JSON.generate({ :name => 'abc', :upload_id => '123' }))

        @command.create
      end
    end

    context 'when zipfile is given' do
      it 'uploads the zipfile and posts build api' do
        @command.should_receive(:upload).and_return(123)
        @command.stub(:check_status)
        @command.stub(:options) { { :clean => false, :path => './', :zipfile => 'abc.zip' } }

        @command.should_receive(:get_value_from_stdin) { 'abc' }

        stub_request(:post, PREFIX + '/api/v2/apps.json')
          .with(:body => JSON.generate({ :name => 'abc', :upload_id => '123' }))

        @command.create
      end
    end
  end

  describe '#update' do
    it 'uploads a file and puts build api' do
      @command.should_receive(:upload).and_return(123)
      @command.stub(:check_status)
      @command.should_receive(:find_app_id) { 123 }

      stub_request(:put, PREFIX + '/api/v2/apps/123.json')

      @command.update
    end
  end
end

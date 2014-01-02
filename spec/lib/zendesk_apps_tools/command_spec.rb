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

  describe '#create' do

    it 'creates app on server' do
      @command.stub(:prepare_api_auth)
      @command.stub(:upload) { 123 }
      @command.stub(:get_value_from_stdin) { 'abc' }

      conn = double('conn')
      @command.stub(:get_connection) { conn }

      request = double('request')
      hash = double('hash')
      conn.should_receive(:post).and_yield(request)
      request.should_receive(:url)
      request.should_receive(:headers).and_return(hash)
      hash.should_receive(:[]=).with(:content_type, 'application/json')

      body = JSON.generate :name => 'abc', :upload_id => '123'
      request.should_receive(:body=).with(body)

      @command.stub(:set_cache)
      @command.stub(:check_status).and_return('OK', nil, nil)

      @command.create
    end

    it 'gives helpful error message when things go wrong in faraday' do
      @command.stub(:prepare_api_auth)
      @command.stub(:upload).and_raise(Faraday::Error::ClientError.new('hey'))

      @command.should_receive(:say_error)
      expect { @command.create }.to_not raise_error(Faraday::Error::ClientError)
    end

  end

end

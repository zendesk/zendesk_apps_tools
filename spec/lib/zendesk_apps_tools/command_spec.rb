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
      request.should_receive(:url).with('/api/v2/apps.json')
      request.should_receive(:headers).and_return(hash)
      hash.should_receive(:[]=).with(:content_type, 'application/json')

      body = JSON.generate :name => 'abc', :upload_id => '123'
      request.should_receive(:body=).with(body)

      @command.stub(:set_cache)
      @command.stub(:check_status).and_return('OK', nil, nil)

      @command.create
    end

    it 'catches errors thrown by faraday and exits' do
      @command.stub(:prepare_api_auth)
      @command.stub(:get_value_from_stdin) { 'abc' }
      @command.stub(:upload).and_raise(Faraday::Error::ClientError.new('hey'))

      expect { @command.create }.to_not raise_error(Faraday::Error::ClientError)
      expect { @command.create }.to raise_error(SystemExit)
    end

  end

  describe '#update' do

    context 'when no errors occur' do
      before do
        @command.stub(:prepare_api_auth)
        @command.stub(:upload) { 123 }

        @app_id = 456

        conn = double('conn')
        @command.stub(:get_connection) { conn }

        request = double('request')
        hash = double('hash')
        conn.should_receive(:put).and_yield(request)
        request.should_receive(:url).with("/api/v2/apps/#{@app_id}.json")
        request.should_receive(:headers).and_return(hash)
        hash.should_receive(:[]=).with(:content_type, 'application/json')

        body = JSON.generate :upload_id => '123'
        request.should_receive(:body=).with(body)

        @command.stub(:set_cache)
        @command.stub(:check_status).and_return('ok', nil, nil)
      end

      it 'updates the app on server when app id is already in cache' do
        @command.stub(:get_cache) { @app_id }

        @command.update
      end

      it 'updates the app on server when app id is not already in cache' do
        @command.stub(:get_cache) { nil }
        @command.stub(:find_app_id) { @app_id }

        @command.update
      end
    end

    it 'catches errors thrown by faraday and exits' do
      @command.stub(:get_cache) { 123 }
      @command.stub(:prepare_api_auth).and_raise(Faraday::Error::ClientError.new('hey'))

      expect { @command.update }.to_not raise_error(Faraday::Error::ClientError)
      expect { @command.update }.to raise_error(SystemExit)
    end

    it 'exits when app id is not found' do
      @command.stub(:get_cache)
      @command.stub(:find_app_id)

      expect { @command.update }.to raise_error(SystemExit)
    end

  end

  describe '#find_app_id' do

    it 'catches errors thrown by faraday and exits' do
      @command.stub(:say_status).and_raise(Faraday::Error::ClientError.new('hey'))

      expect { @command.send(:find_app_id) }.to_not raise_error(Faraday::Error::ClientError)
      expect { @command.send(:find_app_id) }.to raise_error(SystemExit)
    end

  end

end

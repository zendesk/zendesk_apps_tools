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

    @command.stub(:fetch_cache)
    @command.stub(:save_cache)
    @command.stub(:clear_cache)
    @command.stub(:options) { { clean: false, path: './' } }
  end

  describe '#upload' do
    context 'when no zipfile is given' do
      it 'uploads the newly packaged zipfile and returns an upload id' do
        @command.should_receive(:package)
        @command.stub(:options) { { zipfile: nil } }
        Faraday::UploadIO.stub(:new)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .to_return(body: '{ "id": 123 }')

        @command.upload('nah').should == 123
      end
    end

    context 'when zipfile is given' do
      it 'uploads the given zipfile and returns an upload id' do
        @command.stub(:options) { { zipfile: 'app.zip' } }
        Faraday::UploadIO.should_receive(:new).with('app.zip', 'application/zip').and_return(nil)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .to_return(body: '{ "id": 123 }')

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
          .with(body: JSON.generate(name: 'abc', upload_id: '123'))

        @command.create
      end
    end

    context 'when zipfile is given' do
      it 'uploads the zipfile and posts build api' do
        @command.should_receive(:upload).and_return(123)
        @command.stub(:check_status)
        @command.stub(:options) { { clean: false, path: './', zipfile: 'abc.zip' } }

        @command.should_receive(:get_value_from_stdin) { 'abc' }

        stub_request(:post, PREFIX + '/api/v2/apps.json')
          .with(body: JSON.generate(name: 'abc', upload_id: '123'))

        @command.create
      end
    end
  end

  describe '#update' do
    context 'when app id is in cache' do
      it 'uploads a file and puts build api' do
        @command.should_receive(:upload).and_return(123)
        @command.stub(:check_status)
        @command.should_receive(:fetch_cache).with('app_id').and_return(456)

        stub_request(:put, PREFIX + '/api/v2/apps/456.json')

        @command.update
      end
    end

    context 'when app id is not in cache' do
      it 'finds the app id first' do
        @command.instance_variable_set(:@app_id, nil)
        @command.stub(:get_value_from_stdin).and_return('itsme')

        apps = {
          apps: [
            { name: 'hello', id: 123 },
            { name: 'world', id: 124 },
            { name: 'itsme', id: 125 }
          ]
        }

        stub_request(:get, PREFIX + '/api/v2/apps.json')
          .to_return(body: JSON.generate(apps))

        @command.send(:find_app_id).should == 125

        @command.stub(:deploy_app)
        @command.update
      end
    end
  end
end

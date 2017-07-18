require 'spec_helper'
require 'command'
require 'server'
require 'faraday'

describe ZendeskAppsTools::Command do
  PREFIX = 'https://subdomain.zendesk.com'

  before do
    @command = ZendeskAppsTools::Command.new
    @command.instance_variable_set(:@username, 'username')
    @command.instance_variable_set(:@password, 'password')
    @command.instance_variable_set(:@subdomain, 'subdomain')
    @command.instance_variable_set(:@app_id, '123')

    allow(@command.cache).to receive(:fetch)
    allow(@command.cache).to receive(:save)
    allow(@command.cache).to receive(:clear)
    allow(@command).to receive(:options) { { clean: false, path: './' } }
    allow(@command).to receive(:product_names).and_return(['support'])
  end

  describe '#upload' do
    context 'when no zipfile is given' do
      it 'uploads the newly packaged zipfile and returns an upload id' do
        expect(@command).to receive(:package)
        allow(@command).to receive(:options) { { zipfile: nil } }
        allow(Faraday::UploadIO).to receive(:new)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .with(headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })
          .to_return(body: '{ "id": 123 }')

        expect(@command.upload('nah')).to eq(123)
      end
    end

    context 'when zipfile is given' do
      it 'uploads the given zipfile and returns an upload id' do
        allow(@command).to receive(:options) { { zipfile: 'app.zip' } }
        expect(Faraday::UploadIO).to receive(:new).with('app.zip', 'application/zip').and_return(nil)

        stub_request(:post, PREFIX + '/api/v2/apps/uploads.json')
          .with(headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })
          .to_return(body: '{ "id": 123 }')

        expect(@command.upload('nah')).to eq(123)
      end
    end
  end

  describe '#create' do
    context 'when no zipfile is given' do
      it 'uploads a file and posts build api' do
        expect(@command).to receive(:upload).and_return(123)
        allow(@command).to receive(:check_status)
        expect(@command).to receive(:manifest).and_return(double('manifest', name: 'abc', original_parameters: [])).at_least(:once)
        allow(@command).to receive(:options).and_return(clean: false, path: './', config: './settings.json', install: true)
        allow(@command.cache).to receive(:fetch).with('app_id').and_return('987')

        stub_request(:post, PREFIX + '/api/apps.json')
          .with(body: JSON.generate(name: 'abc', upload_id: '123'),
                headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })

        stub_request(:post, PREFIX + '/api/support/apps/installations.json')
          .with(body: JSON.generate(app_id: '987', settings: { name: 'abc' }),
                headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=', 'Content-Type' => 'application/json' })

        @command.create
      end
    end

    context 'when zipfile is given' do
      it 'uploads the zipfile and posts build api' do
        expect(@command).to receive(:upload).and_return(123)
        allow(@command).to receive(:check_status)
        allow(@command).to receive(:options).and_return(clean: false, path: './', zipfile: 'abc.zip', config: './settings.json', install: true)
        expect(@command).to receive(:manifest).and_return(double('manifest', name: 'abc', original_parameters: [])).at_least(:once)

        expect(@command).to receive(:get_value_from_stdin) { 'abc' }

        stub_request(:post, PREFIX + '/api/apps.json')
          .with(body: JSON.generate(name: 'abc', upload_id: '123'),
                headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })

        stub_request(:post, PREFIX + '/api/support/apps/installations.json')
          .with(body: JSON.generate(app_id: nil, settings: { name: 'abc' }),
                headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=', 'Content-Type' => 'application/json' })

        @command.create
      end
    end
  end

  describe '#update' do
    context 'when app id is in cache' do
      it 'uploads a file and puts build api' do
        expect(@command).to receive(:upload).and_return(123)
        allow(@command).to receive(:check_status)
        expect(@command.cache).to receive(:fetch).with('app_id').and_return(456)

        stub_request(:put, PREFIX + '/api/v2/apps/456.json')
          .with(headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })

        @command.update
      end
    end

    context 'when app id is not in cache' do
      it 'finds the app id first' do
        @command.instance_variable_set(:@app_id, nil)
        allow(@command).to receive(:get_value_from_stdin).and_return('itsme')

        apps = {
          apps: [
            { name: 'hello', id: 123 },
            { name: 'world', id: 124 },
            { name: 'itsme', id: 125 }
          ]
        }

        stub_request(:get, PREFIX + '/api/apps.json')
          .with(headers: { 'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ=' })
          .to_return(body: JSON.generate(apps))

        expect(@command.send(:find_app_id)).to eq(125)

        allow(@command).to receive(:deploy_app)
        @command.update
      end
    end
  end

  describe '#version' do
    context 'when -v is run' do
      it 'shows the version' do
        old_v = Gem::Version.new '0.0.1'
        new_v = nil

        expect(@command).to receive(:say) { |arg| new_v = Gem::Version.new arg }
        @command.version

        expect(old_v).to be < new_v
      end
    end
  end

  describe '#server' do
    it 'runs the server' do
      path = './tmp/tmp_app'
      allow(@command).to receive(:options) { { path: path } }
      expect(ZendeskAppsTools::Server).to receive(:run!)
      @command.directory('app_template_iframe', path, {})
      @command.server
    end
  end
end

require 'spec_helper'
require 'zendesk_apps_tools/deploy'
require 'json'
require 'faraday'

describe ZendeskAppsTools::Deploy do
  let(:subject_class) { Class.new { include ZendeskAppsTools::Deploy } }

  describe '#find_app_id' do
    let(:valid_response_body) {
      {
        apps: [
          { id: 22, name: 'notification_app' },
          { id: 99, name: 'time_tracking_app' }
        ]
      }.to_json
    }
    let(:valid_api_response) { Faraday::Response.new({ body: valid_response_body, status: 200}) }
    let(:invalid_api_response) { Faraday::Response.new({ body: {}.to_json, status: 200}) }
    let(:failed_api_response) { Faraday::Response.new({ body: {}.to_json, status: 403}) }
    let(:connection_error_msg) { /Unable to retrieve apps/ }
    let(:app_lookup_error_msg) { /App not found/ }

    def mocked_instance_methods_and_api(app_name, api_response)
      subject = subject_class.new
      allow(subject).to receive(:say_status)
      allow(subject).to receive(:get_value_from_stdin) { app_name }
      allow(subject).to receive_message_chain(:cached_connection, :get) { api_response }
      subject
    end

    context 'receives an invalid api response' do
      it 'errors and exits system' do
        subject = mocked_instance_methods_and_api('notification_app', invalid_api_response)

        expect(subject).to receive(:say_error).with(connection_error_msg)
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

   context 'user inputs the wrong credentials' do
      it 'errors and exits system' do
        subject = mocked_instance_methods_and_api('notification_app', failed_api_response)

        expect(subject).to receive(:say_error).with(connection_error_msg)
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is NOT in api response' do
      it 'errors and exits system' do
        subject = mocked_instance_methods_and_api('random_app_name', valid_api_response)

        expect(subject).to receive(:say_error).with(app_lookup_error_msg)
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is in api response' do
      it 'returns app id 22 for notification_app' do
        subject = mocked_instance_methods_and_api('notification_app', valid_api_response)
        allow(subject).to receive_message_chain(:cache, :save)

        expect(subject.find_app_id).to eq(22)
      end

      it 'returns app id 99 for time_tracking_app' do
        subject = mocked_instance_methods_and_api('time_tracking_app', valid_api_response)
        allow(subject).to receive_message_chain(:cache, :save)

        expect(subject.find_app_id).to eq(99)
      end
    end
  end

  describe '#check_job' do
    let(:random_job_id) { 9999 }
    let(:completed_api_response_body) { {'status' => 'completed'} }
    let(:failed_api_response_body)    { {'status' => 'failed', 'message' => 'You failed!'} }

    let(:subject) { subject_class.new }

    context 'response status is failed' do
      it 'errors and exit' do
        allow(subject).to receive_message_chain(:cached_connection, :get, :body) { failed_api_response_body.to_json  }
        allow(subject).to receive(:say_status).with(@command, failed_api_response_body['message'], :red) { exit }

        expect { subject.check_job(random_job_id)}.to raise_error(SystemExit)
      end
    end

    context 'response status is completed' do
      it 'caches subdomain, username and app_id' do
        subject = subject_class.new
        allow(subject).to receive_message_chain(:cached_connection, :get, :body) { completed_api_response_body.to_json  }
        allow(subject).to receive_message_chain(:cache, :save)
        allow(subject).to receive(:say_status).with(@command, "OK")

        subject.check_job(random_job_id)
      end
    end
  end
end

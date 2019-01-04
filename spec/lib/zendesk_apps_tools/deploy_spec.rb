require 'spec_helper'
require 'zendesk_apps_tools/deploy'
require 'json'

describe ZendeskAppsTools::Deploy do
  let(:subject_class) { Class.new { include ZendeskAppsTools::Deploy } }

  describe '#find_app_id' do
    let (:api_response_with_installations) {
      {
        installations: [
          { id: 1, app_id: 22, settings: { name: 'notification_app' }},
          { id: 2, app_id: 99, settings: { name: 'time_tracking_app' }}
        ]
      }.to_json
    }

    def mocked_instance_methods_and_api(app_name, api_response)
      subject = subject_class.new
      allow(subject).to receive(:say_status)
      allow(subject).to receive(:get_value_from_stdin) { app_name }
      allow(subject).to receive_message_chain(:cached_connection, :get, :body) { api_response }
      subject
    end

    context 'is unable to get a valid api response' do
      it 'errors and exits system' do
        invalid_api_response = {}
        subject = mocked_instance_methods_and_api('notification_app', invalid_api_response)

        expect(subject).to receive(:say_error).with(
          "Unable to retrieve installations. Please check your internet connection."
        )
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is NOT in api response' do
      it 'errors and exits system' do
        subject = mocked_instance_methods_and_api('random_app_name', api_response_with_installations)

        expect(subject).to receive(:say_error).with(
          "App not found. Please verify that your credentials, subdomain, and app name are correct."
        )
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is in api response' do
      it 'returns app id 22 for notification_app' do
        subject = mocked_instance_methods_and_api('notification_app', api_response_with_installations)
        allow(subject).to receive_message_chain(:cache, :save)

        expect(subject.find_app_id).to eq(22)
      end

      it 'returns app id 99 for time_tracking_app' do
        subject = mocked_instance_methods_and_api('time_tracking_app', api_response_with_installations)
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

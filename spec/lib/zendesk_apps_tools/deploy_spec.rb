require 'spec_helper'
require 'zendesk_apps_tools/deploy'
require 'json'

describe ZendeskAppsTools::Deploy do
  let(:api_response) do
   {
     'apps'=> [
        { 'name'=> 'notification_app', 'id'=> 22 },
        { 'name'=> 'time_tracking_app', 'id' => 99 }
      ]
    }.to_json
  end

  let(:subject_class) do
    Class.new do
      include ZendeskAppsTools::Deploy
      attr_reader :app_name

      def initialize(app_name)
        @app_name = app_name
      end

      def get_value_from_stdin(text)
        app_name
      end
    end
  end

  describe '#find_app_id' do

    context 'user inputs an app name that is NOT in api response' do
      it 'errors and exits system' do
        subject = subject_class.new('random_app_name')
        allow(subject).to receive(:say_status)
        allow(subject).to receive_message_chain(:cached_connection, :get, :body) { api_response }

        expect(subject).to receive(:say_error).with(
          "App not found. " \
          "Please verify that your credentials, subdomain, and app name are correct."
        )
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is in api response' do
      define_method(:mock_methods_and_api) do |subject|
        allow(subject).to receive_message_chain(:cache, :save)
        allow(subject).to receive(:say_status)
        allow(subject).to receive_message_chain(:cached_connection, :get, :body) { api_response }
      end

      it 'returns app id 22 for notification_app' do
        subject = subject_class.new('notification_app')
        mock_methods_and_api(subject)
        expect(subject.find_app_id).to eq(22)
      end

      it 'returns app id 99 for notification_app' do
        subject = subject_class.new('time_tracking_app')
        mock_methods_and_api(subject)
        expect(subject.find_app_id).to eq(99)
      end
    end
  end
end

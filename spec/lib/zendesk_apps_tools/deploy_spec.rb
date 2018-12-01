require 'spec_helper'
require 'zendesk_apps_tools/deploy'
require 'json'

describe ZendeskAppsTools::Deploy do
  let(:mock_response) do
    Class.new do
      attr_reader :body
      def initialize(json_body)
        @body = json_body
      end

      def get(uri)
        self
      end
    end
  end

  let(:subject_class) do
    Class.new do
      include ZendeskAppsTools::Deploy
      attr_reader :get_connection, :app_name

      def initialize(get_response, app_name)
        @get_connection = get_response
        @app_name = app_name
      end

      def connection(multipart = nil)
        get_connection
      end

      def get_value_from_stdin(text)
        app_name
      end
    end
  end

  describe '#find_app_id' do

    let(:api_response) do
      mock_response.new(
       {
         'apps'=> [
            { 'name'=> 'notification_app', 'id'=> 22 },
            { 'name'=> 'time_tracking_app', 'id' => 99 }
          ]
        }.to_json
      )
    end

    let(:subject) { subject_class.new(api_response) }

    context 'user inputs an app name that is NOT in api response' do
      it 'errors and exits system' do
        subject = subject_class.new(api_response, 'random_app_name')
        allow(subject).to receive_message_chain(:say_status, :command, :text)

        expect(subject).to receive(:say_error).with(
          "App not found. " \
          "Please verify that your credentials, subdomain, and app name are correct."
        )
        expect { subject.find_app_id }.to raise_error(SystemExit)
      end
    end

    context 'user inputs an app name that is in api response' do
      it 'returns app id 22 for notification_app' do
        subject = subject_class.new(api_response, 'notification_app')
        allow(subject).to receive_message_chain(:cache, :save)
        allow(subject).to receive_message_chain(:say_status, :command, :text)

        expect(subject.find_app_id).to eq(22)
      end

      it 'returns app id 99 for notification_app' do
        subject = subject_class.new(api_response, 'time_tracking_app')
        allow(subject).to receive_message_chain(:cache, :save)
        allow(subject).to receive_message_chain(:say_status, :command, :text)

        expect(subject.find_app_id).to eq(99)
      end
    end
  end
end

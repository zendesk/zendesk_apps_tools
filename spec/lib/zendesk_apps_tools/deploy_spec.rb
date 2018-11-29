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
      attr_reader :get_connection

      def initialize(get_response)
        @get_connection = get_response
      end

      def connection(multipart = nil)
        get_connection
      end

      def say_status(command, text)
      end

      def get_value_from_stdin(text)
        'app_2'
      end

      def say(message, color = nil)
      end
    end
  end

  let(:response_with_apps) {
    {
      'apps'=> [
        {'name'=> 'app_1', 'id'=> 1},
        {'name'=> 'app_2', 'id'=> 2}
      ]
    }.to_json
  }

  describe '#find_app_id' do
    it 'exits system if apps_json is empty' do
      subject = subject_class.new(mock_response.new(''))

      expect(subject).to receive(:say_error).with(
        "App not found. " \
        "Please verify that your credentials, subdomain, and app name are correct."
      )
      expect { subject.find_app_id }.to raise_error(SystemExit)
    end

    it 'returns app id if is in response_with_apps' do
      subject = subject_class.new(mock_response.new(response_with_apps))
      allow(subject).to receive_message_chain(:cache, :save)
      expect(subject.find_app_id).to eq(2)
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'
require 'zendesk_apps_tools/common'

describe ZendeskAppsTools::Common do
  let(:subject_class) do
    Class.new do
      include ZendeskAppsTools::Common
      def options
        {}
      end

      def say(message, color = nil)
      end

      def ask(prompt, options)
      end
    end
  end
  let(:subject) do
    subject_class.new
  end

  describe '#get_value_from_stdin' do
    it 'errors if unattended' do
      allow(subject).to receive(:options).and_return(unattended: true)
      expect { subject.get_value_from_stdin('prompt') }.to raise_error(SystemExit)
    end

    it 'returns the asked value' do
      allow(subject).to receive(:ask).and_return('test value')
      expect(subject.get_value_from_stdin('prompt')).to eq 'test value'
    end
  end

  describe '#get_password_from_stdin' do
    it 'errors if unattended' do
      allow(subject).to receive(:options).and_return(unattended: true)
      expect { subject.get_password_from_stdin('prompt') }.to raise_error(SystemExit)
    end

    it 'returns the asked value' do
      allow(subject).to receive(:ask).and_return('test value')
      expect(subject.get_password_from_stdin('prompt')).to eq 'test value'
    end

    it 'does not echo' do
      expect(subject).to receive(:ask).with('prompt', hash_including(echo: false))
      subject.get_password_from_stdin('prompt')
    end
  end

  describe '#say_error' do
    it 'outputs a red message' do
      expect(subject).to receive(:say).with('goodbye world', :red)
      subject.say_error 'goodbye world'
    end
  end

  describe '#say_error_and_exit' do
    it 'calls say_error and quits' do
      expect(subject).to receive(:say).with('goodbye world', :red)
      expect { subject.say_error_and_exit 'goodbye world' }.to raise_error(SystemExit)
    end
  end

  describe '.shared_options' do
    it 'calls method_option three times' do
      expect(subject.class).to receive(:method_option).exactly(3).times
      subject.class.shared_options
    end

    it 'respects `except`' do
      expect(subject.class).to receive(:method_option).exactly(2).times
      subject.class.shared_options(except: [:clean])
    end
  end

  describe 'json_or_die' do
    it 'return json object if valid input is provided' do
      expect(subject).not_to receive(:say)
      expect(subject.json_or_die '{ "key":"value" }').to eq({ 'key'=>'value' })
    end

    it 'raise error if invalid input is provided' do
      expect(subject).to receive(:say).with(/is an invalid JSON$/, :red)
      expect { subject.json_or_die '{ "key"="value" }' }.to raise_error(SystemExit)
    end
  end
end

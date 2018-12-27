require 'spec_helper'
require 'api_connection'

describe ZendeskAppsTools::APIConnection do
  describe 'EMAIL_REGEX' do
    let(:email_regex) { ZendeskAppsTools::APIConnection::EMAIL_REGEX }
    define_method(:matches_email?) { |email| !!email_regex.match(email) }

    it 'does not match invalid email addresses' do
      expect(matches_email?('username')).to eq(false)
      expect(matches_email?('username.com')).to eq(false)
      expect(matches_email?('u!sername@email.com')).to eq(false)
      expect(matches_email?('username@email.com/token:password')).to eq(false)
      expect(matches_email?('username@email.com/')).to eq(false)
    end

    it 'will match valid email addresses' do
      expect(matches_email?('username@email.com')).to eq(true)
      expect(matches_email?('username123@e-mail.com')).to eq(true)
    end

    it 'will match valid email addresses with api_token' do
      expect(matches_email?('username@email.com/token')).to eq(true)
    end
  end

  describe 'CONSTANTS' do
    let(:subdomain_validation_pattern) { ZendeskAppsTools::APIConnection::SUBDOMAIN_VALIDATION_PATTERN }
    let(:url_validation_pattern)       { ZendeskAppsTools::APIConnection::ZENDESK_URL_VALIDATION_PATTERN }
    let(:default_url_template)         { ZendeskAppsTools::APIConnection::DEFAULT_URL_TEMPLATE }

    describe 'DEFAULT_URL_TEMPLATE' do
      context '% subdomain (used in private method full_url)' do
        it 'replaces %s with subdomain in template' do
          user_input_subdomain = 'my-subdomain'
          expect(default_url_template % user_input_subdomain).to eq("https://my-subdomain.zendesk.com/")
        end
      end
    end

    describe 'SUBDOMAIN_VALIDATION_PATTERN' do
      context 'valid_subdomain? (a private method)' do
        define_method(:valid_subdomain?) { |subdomain| !!subdomain_validation_pattern.match(subdomain) }

        it 'returns false if subdomain is NOT in valid format' do
          expect(valid_subdomain?('sub.domain')).to eq(false)
          expect(valid_subdomain?('sub!domain')).to eq(false)
          expect(valid_subdomain?('sub~domain')).to eq(false)
          expect(valid_subdomain?('sub_domain')).to eq(false)
        end

        it 'returns true if subdomain is in valid format' do
          expect(valid_subdomain?('subDomain')).to eq(true)
          expect(valid_subdomain?('SUBDOMAIN')).to eq(true)
          expect(valid_subdomain?('subdomain')).to eq(true)
          expect(valid_subdomain?('sub-domain')).to eq(true)
        end
      end
    end

    describe 'ZENDESK_URL_VALIDATION_PATTERN' do
      context 'valid_full_url? (a private method)' do
        define_method(:valid_full_url?) { |subdomain|  !!url_validation_pattern.match(subdomain) }

        context 'with regular zendesk urls' do
          it 'returns false when subdomain does not match full url pattern' do
            expect(valid_full_url?('www.subdomain.com')).to eq(false)
            expect(valid_full_url?('subdomain.com')).to eq(false)
          end

          it 'returns true when subdomain does match full url pattern' do
            expect(valid_full_url?('http://z3n-subdomain.zendesk.com')).to eq(true)
            expect(valid_full_url?('https://subdomain.zendesk.com')).to eq(true)
            expect(valid_full_url?('https://my-subdomain.zendesk-staging.com')).to eq(true)
          end
        end

        context 'with host map urls' do
          it 'returns true when subdomain of customized urls matches full url pattern' do
            expect(valid_full_url?('https://subdomain.com')).to eq(true)
            expect(valid_full_url?('https://www.subdomain.com')).to eq(true)
            expect(valid_full_url?('https://subdomain.au')).to eq(true)
          end
        end
      end
    end
  end

  let(:subject_class) do
    Class.new do
      include ZendeskAppsTools::APIConnection
      attr_reader :cache, :subdomain, :username, :password

      def initialize(subdomain = nil, username = nil, password = nil)
        @cache = {
          'subdomain' => @subdomain = subdomain,
          'username' => @username = username,
        }

        @cache['password'] = @password = password if password
      end
    end
  end

  describe '#prepare_api_auth' do
    let(:url_error_message)   { ZendeskAppsTools::APIConnection::URL_ERROR_MSG }
    let(:email_error_message) { ZendeskAppsTools::APIConnection::EMAIL_ERROR_MSG }

    context 'invalid subdomain' do
      it 'errors and exit' do
        subject = subject_class.new('bad!subdomain')

        expect(subject).to receive(:say_error_and_exit).with(url_error_message) { exit }

        expect { subject.prepare_api_auth }.to raise_error(SystemExit)
      end
    end

    context 'invalid full url' do
      it 'errors and exit' do
        subject = subject_class.new('www.keith.com')

        expect(subject).to receive(:say_error_and_exit).with(url_error_message) { exit }

        expect { subject.prepare_api_auth }.to raise_error(SystemExit)
      end
    end

    context 'with invalid email format' do
      it 'errors and exit' do
        subject = subject_class.new('subdomain', 'bad-email')

        expect(subject).to receive(:say_error_and_exit).with(email_error_message) { exit }

        expect { subject.prepare_api_auth }.to raise_error(SystemExit)
      end
    end
  end

  describe '#get_connection' do
    context 'with all credentials (available in cache)' do
      let(:subject_with_all_credentials) { subject_class.new('subdomain', 'username', 'password') }

      it 'does not call prepare_api_auth' do
        expect(subject_with_all_credentials).to_not receive(:prepare_api_auth)
        subject_with_all_credentials.get_connection
      end

      it 'creates a faraday client for network requests' do
        expect(subject_with_all_credentials.get_connection).to be_instance_of(Faraday::Connection)
      end
    end

    context 'with one or more missing credentials (in cache)' do
      let(:subject_with_1_missing_credential)  { subject_class.new('subdomain', 'username') }
      let(:subject_with_2_missing_credentials) { subject_class.new('subdomain') }

      it 'calls prepare_api_auth only once' do
        expect(subject_with_1_missing_credential).to receive(:prepare_api_auth).exactly(1).times
        subject_with_1_missing_credential.get_connection

        expect(subject_with_2_missing_credentials).to receive(:prepare_api_auth).exactly(1).times
        subject_with_2_missing_credentials.get_connection
      end
    end
  end
end

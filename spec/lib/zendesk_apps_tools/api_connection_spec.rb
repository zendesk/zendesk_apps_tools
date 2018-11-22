require 'spec_helper'
require 'api_connection'
require 'common'

describe ZendeskAppsTools::APIConnection do
  let(:subdomain_validation_pattern) { ZendeskAppsTools::APIConnection::SUBDOMAIN_VALIDATION_PATTERN }
  let(:url_validation_pattern)       { ZendeskAppsTools::APIConnection::ZENDESK_URL_VALIDATION_PATTERN }
  let(:default_url_template)         { ZendeskAppsTools::APIConnection::DEFAULT_URL_TEMPLATE }

  describe 'CONSTANTS' do
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
          expect(valid_subdomain?('SUBDOMAIN')).to eq(false)
          expect(valid_subdomain?('subDomain')).to eq(false)
        end

        it 'returns true if subdomain is in valid format' do
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
end

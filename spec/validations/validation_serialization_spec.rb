require 'zendesk_apps_support'
require 'json'

describe ZendeskAppsSupport::Validations::ValidationError do

  describe '#to_json' do
    let(:key)   { 'foo.bar' }
    let(:data)  { { 'baz' => 'quux' } }
    let(:error) { ZendeskAppsSupport::Validations::ValidationError.new(key, data) }
    subject     { error.to_json }

    it do
      should == {
                  'class' => error.class.to_s,
                  'key'   => error.key,
                  'data'  => error.data
                }.to_json
    end
  end

  describe '.from_json' do

    subject { ZendeskAppsSupport::Validations::ValidationError.from_json(json) }

    context 'for a generic error' do
      let(:json) do
        {
          'class' => 'ZendeskAppsSupport::Validations::ValidationError',
          'key'   => 'foo.bar.baz',
          'data'  => { 'quux' => 'yargle' }
        }.to_json
      end

      it { should be_a(ZendeskAppsSupport::Validations::ValidationError) }

      its(:key) { should == 'foo.bar.baz' }

      its(:data) { should == { 'quux' => 'yargle' } }
    end

    context 'for a JSHint error' do
      let(:json) do
        {
          'class'         => 'ZendeskAppsSupport::Validations::JSHintValidationError',
          'file'          => 'foo.js',
          'jshint_errors' => [ { 'line' => 55, 'reason' => 'Yuck' } ]
        }.to_json
      end

      it { should be_a(ZendeskAppsSupport::Validations::JSHintValidationError) }

      its(:key) { should == :jshint_errors }

      its(:jshint_errors) do
        should == [ { 'line' => 55, 'reason' => 'Yuck' } ]
      end
    end
  end

end

require 'zendesk_apps_support'

describe ZendeskAppsSupport::Package do
  let(:error) do
    ZendeskAppsSupport::Validations::ValidationError
  end
  let(:package) do
    ZendeskAppsSupport::Package.new('/dir')
  end

  it "validates manifest presence" do
    errors = %w(missing_manifest missing_source).collect{|k| error.new(k.to_sym).to_s}
    package.validate.map(&:to_s).should eql(errors)
  end

end

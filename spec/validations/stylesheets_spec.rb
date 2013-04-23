require 'zendesk_apps_support'

describe ZendeskAppsSupport::Validations::Stylesheets do
  it 'does not return errors if there is no custom css' do

    package = stub(:customer_css => "")
    ZendeskAppsSupport::Validations::Stylesheets.call(package).should be_empty
  end

  it 'does not return errors for valid css' do
    valid_css = <<-CSS
.my-class {
  border: solid 1px black;
}
    CSS
    package = stub(:customer_css => valid_css)

    errors = ZendeskAppsSupport::Validations::Stylesheets.call(package)
    errors.should be_empty
  end

  it 'returns style sheet validation error for invalid css' do
    invalid_css = <<-CSS
.my-class {
  border: }
}
    CSS
    package = stub(:customer_css => invalid_css)

    errors = ZendeskAppsSupport::Validations::Stylesheets.call(package)
    errors.count.should == 1
    errors.first.to_s.should match /Sass error: Invalid CSS after.*/
  end
end

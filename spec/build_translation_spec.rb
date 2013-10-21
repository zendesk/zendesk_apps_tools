require 'zendesk_apps_support'
include ZendeskAppsSupport::BuildTranslation

describe ZendeskAppsSupport::BuildTranslation do

  describe '#app_translations' do

    let(:en_json) {
      {
        "app" => {
          "description" => "Shows related tickets",
          "title" => "Related tickets",
          "parameters" => {
            "disable_tooltip" => {
              "label" => "Disable tooltip"
            }
          }
        },
        "parent_without_child" => "Foo",
        "parent_with_child" => {
          "child" => "Foo"
        },
        "parent_with_child_title" => {
          "title" => "Foo"
        },
        "parent_with_zendesk_tranlation" => {
          "title" => "Bar",
          "value" => "Foo"
        },
        "parent_with_child_title_nested" => {
          "title" => {
            "value" => "Foo"
          }
        },
        "parent_with_nested_invalid_zendesk_translation" => {
          "title" => {
            "title" => "Bar",
            "desc" => "Foo"
          }
        },
        "parent_with_nested_zendesk_translation" => {
          "title" => {
            "title" => "Bar",
            "value" => "Foo"
          }
        }
      }
    }

    context "reformat translations" do

      before do
        @translations = remove_zendesk_keys(en_json)
      end

      it "value is correct parent without a child" do
        @translations['parent_without_child'].should eq 'Foo'
      end

      it "value is correct parent with a child" do
        @translations['parent_with_child']['child'].should eq 'Foo'
      end

      it "value is correct parent with a child with a title" do
        @translations['parent_with_child_title']['title'].should eq 'Foo'
      end

      it "value is correct parent with a zendesk translation" do
        @translations['parent_with_child_title_nested']['title']['value'].should eq 'Foo'
      end

      it "value is correct parent with a child that has a nested zendesk translation" do
        @translations['parent_with_nested_zendesk_translation']['title'].should eq 'Foo'
      end

      it "value is correct parent with a child that has an invalid nested zendesk translation" do
        @translations['parent_with_nested_invalid_zendesk_translation']['title'].should eq({ "title" => "Bar", "desc" => "Foo" })
      end

    end

  end

end

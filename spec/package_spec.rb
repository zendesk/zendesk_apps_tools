require 'zendesk_apps_support'

describe ZendeskAppsSupport::Package do

  before do
    @package = ZendeskAppsSupport::Package.new('spec/template/app')
  end

  describe 'files' do
    it 'should return all the files within the app folder excluding files in tmp folder' do
      @package.files.map(&:relative_path).should == %w(app.css app.js assets/logo-small.png assets/logo.png manifest.json.tt templates/layout.hdbs translations/en.json)
    end
  end

  describe 'template_files' do
    it 'should return all the files in the templates folder within the app folder' do
      @package.template_files.map(&:relative_path).should == %w(templates/layout.hdbs)
    end
  end

  describe 'translation_files' do
    it 'should return all the files in the translations folder within the app folder' do
      @package.translation_files.map(&:relative_path).should == %w(translations/en.json)
    end
  end

  describe 'compiled_templates' do
    it 'should compile stylesheets and templates' do
      compiled_templates = @package.compiled_templates(0, 'http://localhost:4567')

      expected = {"layout"=>"<style>\n.app-0 header {\n  border-bottom: 1px dotted #CCC;\n  margin-bottom: 12px; }\n  .app-0 header h3 {\n    line-height: 30px; }\n  .app-0 header hr {\n    margin-top: 0; }\n  .app-0 header .logo {\n    background: transparent url(\"http://localhost:4567/logo-small.png\") no-repeat;\n    background-size: 25px 25px;\n    float: right;\n    height: 25px;\n    width: 25px; }\n  .app-0 header .app-warning-icon {\n    cursor: pointer;\n    float: right;\n    margin-left: 2px;\n    padding: 5px; }\n.app-0 h3 {\n  font-size: 14px; }\n.app-0 footer {\n  background: none;\n  border: 0; }\n.app-0 h1 {\n  color: red; }\n  .app-0 h1 span {\n    color: green; }\n</style>\n"}
      compiled_templates.should == expected
    end
  end

end
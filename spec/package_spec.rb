require 'zendesk_apps_support'

describe ZendeskAppsSupport::Package do

  before do
    @package = ZendeskAppsSupport::Package.new('tmp/template/app')
  end

  describe 'files' do
    it 'should return all the files within the app folder excluding files in tmp folder' do
      @package.files.map(&:relative_path).should == %w(app.js assets/logo-small.png assets/logo.png manifest.json.tt templates/layout.hdbs translations/en.json)
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

end
require 'zendesk_apps_support'

describe ZendeskAppsSupport::Package do

  before do
    @package = ZendeskAppsSupport::Package.new('spec/template/app')
  end

  describe 'files' do
    it 'should return all the files within the app folder excluding files in tmp folder' do
      @package.files.map(&:relative_path).should == %w(app.css app.js assets/logo-small.png assets/logo.png manifest.json templates/layout.hdbs translations/en.json)
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

  describe 'readified_js' do
    it 'should generate js ready for installation' do
      js = @package.readified_js(nil, 0, 'http://localhost:4567')
      expected =<<HERE
(function() {
    with( require('apps/framework/app_scope') ) {

        var source = (function() {

  return {
    events: {
      'app.activated':'doSomething'
    },

    doSomething: function() {
    }
  };

}());
;

        ZendeskApps["ABC"] = ZendeskApps.defineApp(source)
                .reopenClass({ location: "ticket_sidebar" })
                .reopen({
                    assetUrlPrefix: "http://localhost:4567",
                    appClassName: "app-0",
                    author: {
                        name: "John Smith",
                        email: "john@example.com"
                    },
                    translations: {"app":{\"description\":\"Play the famous zen tunes in your help desk.\",\"name\":\"Buddha Machine\"}},
                    templates: {"layout":"<style>\\n.app-0 header {\\n  border-bottom: 1px dotted #CCC;\\n  margin-bottom: 12px; }\\n  .app-0 header h3 {\\n    line-height: 30px; }\\n  .app-0 header hr {\\n    margin-top: 0; }\\n  .app-0 header .logo {\\n    background: transparent url(\\"http://localhost:4567/logo-small.png\\") no-repeat;\\n    background-size: 25px 25px;\\n    float: right;\\n    height: 25px;\\n    width: 25px; }\\n  .app-0 header .app-warning-icon {\\n    cursor: pointer;\\n    float: right;\\n    margin-left: 2px;\\n    padding: 5px; }\\n.app-0 h3 {\\n  font-size: 14px; }\\n.app-0 footer {\\n  background: none;\\n  border: 0; }\\n.app-0 h1 {\\n  color: red; }\\n  .app-0 h1 span {\\n    color: green; }\\n</style>\\n<header>\\n  <span class=\\"logo\\"/>\\n  <h3>{{setting \\"name\\"}}</h3>\\n</header>\\n<section data-main/>\\n<footer>\\n  <a href=\\"mailto:{{author.email}}\\">\\n    {{author.name}}\\n  </a>\\n</footer>\\n</div>"},
                    frameworkVersion: "0.5"
                });

    }

    ZendeskApps["ABC"].install({"id":0,"app_id":0,"settings": {\"title\":\"ABC\"}});

}());
HERE
      js.should == expected
    end
  end
end
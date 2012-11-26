require 'zendesk_apps_support'

describe ZendeskAppsSupport::AppHash do

  describe 'stale?' do
    before do
      hash_file = 'tmp/.zendesk_app_hash'
      File.delete(hash_file) if File.exists?(hash_file)
      package = ZendeskAppsSupport::Package.new("template/app")
      @app_hash = ZendeskAppsSupport::AppHash.new(package, Pathname.new("template/app/tmp"))
    end

    it 'should be stale when the app hash file does not exist' do
      @app_hash.should be_stale
    end

    it 'should not be stale when the app hash file is created and the content of the package has not changed' do
      @app_hash.stale?

      @app_hash.should_not be_stale
    end

    it 'should be stale when the content is changed in the package' do
      test_file = 'template/app/test.txt'
      File.delete(test_file) if File.exists?(test_file)
      @app_hash.stale?
      File.open(test_file, 'w') {|f| f.write 'test'}

      stale = @app_hash.stale?
      File.delete(test_file)

      stale.should be_true
    end
  end
end
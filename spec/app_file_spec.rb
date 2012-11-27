require 'zendesk_apps_support'

describe ZendeskAppsSupport::AppFile do

  before do
    package = mock('Package', :root => Pathname("tmp/template/app/templates/"))
    @file = ZendeskAppsSupport::AppFile.new(package, 'layout.hdbs')
  end

  describe '=~' do
    it 'should test against the relative path of the file' do
      @file.should =~ /layout/
    end
  end

  describe 'read' do
    it 'should read file content' do
      @file.read.should =~ /<header>/
    end
  end

  describe 'to_s' do
    it 'should return file name' do
      @file.to_s.should == 'layout.hdbs'
    end
  end
end
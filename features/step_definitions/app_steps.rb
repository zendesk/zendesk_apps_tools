require 'tmpdir'
require 'fileutils'
require 'pathname'

Given /^an app directory$/ do
  r = rand(2 ** 20)
  @app_dir = Pathname.new( Dir.tmpdir ).join("app_#{r}").tap do |path|
    FileUtils.mkdir_p path
  end
  raise "Could not create app dir" unless Dir.exists?(@app_dir.to_s)
end

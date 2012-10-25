require 'tmpdir'
require 'fileutils'
require 'pathname'

Given /^an app directory$/ do
  r = rand(2 ** 20)
  @app_dir = Pathname.new( Dir.tmpdir ).join("app_#{r}").tap do |path|
    FileUtils.mkdir_p path
  end
  # Set the Aruba temp dir to the app dir:
  @dirs = [ @app_dir ]
  raise "Could not create app dir" unless Dir.exists?(@app_dir.to_s)
end

Given /^the file "(.*?)" with:$/ do |filename, contents|
  raise "No app dir exists. You forgot the 'Given an app directory' step" unless @app_dir
  filename = @app_dir.join(filename)
  FileUtils.mkdir_p File.dirname(filename)
  File.open(filename, 'w') do |f|
    f << contents
  end
end

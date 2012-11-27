Given /^an app directory "(.*?)" exists$/ do |app_dir|
  @app_dir = app_dir
  FileUtils.rm_rf(@app_dir)
  FileUtils.mkdir_p(@app_dir)
end

When /^I run "(.*?)" command with the following details:$/ do |cmd, table|
  IO.popen(cmd, "w+") do |pipe|
    key = table.rows_hash
    pipe.puts key["author name"]
    pipe.puts key["author email"]
    pipe.puts key["app name"]
    pipe.puts @app_dir
    pipe.close_write
    @output = pipe.readlines
    @output.each {|line| puts line}
  end
end

Then /^the app file "(.*?)" is created with:$/ do |file, content|
  File.read(file).gsub(' ', '').should == content.gsub(' ', '')
end


Then /^the zip file should exist in directory "(.*?)"$/ do |path|
  Dir[path + '/app-*.zip'].size.should == 1
end

Given /^I remove file "(.*?)"$/ do |file|
  File.delete(file)
end

Then /^the zip file in "(.*?)" folder should not exist$/ do |path|
  Dir[path + '/app-*.zip'].size.should == 0
end
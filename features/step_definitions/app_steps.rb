Given /^an app directory "(.*?)" exists$/ do |app_dir|
  @app_dir = app_dir
  FileUtils.rm_rf(@app_dir)
  FileUtils.mkdir_p(@app_dir)
end

Given /^an app is created in directory "(.*?)"$/ do |app_dir|
  steps %Q{
    Given an app directory "#{app_dir}" exists
    And I run "bundle exec bin/zat new" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | app name     | John Test App     |
  }
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
  File.read(file).chomp.gsub(' ', '').should == content.gsub(' ', '')
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
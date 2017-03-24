require 'fileutils'
require 'zip'
require 'English'

When /^I move to the app directory$/ do
  @previous_dir = Dir.pwd
  Dir.chdir(@app_dir)
end

When /^I reset the working directory$/ do
  Dir.chdir(@previous_dir)
end

Given /^an app directory "(.*?)" exists$/ do |app_dir|
  @app_dir = app_dir
  FileUtils.rm_rf(@app_dir)
  FileUtils.mkdir_p(@app_dir)
end

Given /^a(n|(?: v1)) app is created in directory "(.*?)"$/ do |version, app_dir|
  v1 = !!version[/v1/]
  steps %(
    Given an app directory "#{app_dir}" exists
    And I run "zat new #{'--v1' if v1}" command with the following details:
      | author name  | John Citizen      |
      | author email | john@example.com  |
      | author url   | http://myapp.com  |
      | app name     | John Test App     |
      #{'| iframe uri   | assets/iframe.html |' unless v1}
      | app dir      | #{app_dir}        |
    )
end

Given /^a \.zat file in "(.*?)"/ do |app_dir|
  f = File.new(File.join(app_dir, '.zat'), 'w')
  f.write(JSON.dump(username: 'test@user.com', password: 'hunter2', subdomain: 'app-account'))
  f.close
end

When /^I run "(.*?)" command with the following details:$/ do |cmd, table|
  IO.popen(cmd, 'w+') do |pipe|
    # [ ['parameter name', 'value'] ]
    table.raw.each do |row|
      pipe.puts row.last
    end
    pipe.close_write
    @output = pipe.readlines
    @output.each { |line| puts line }
  end
end

When /^I create a symlink from "(.*?)" to "(.*?)"$/ do |src, dest|
  @link_destname = File.basename(dest)
  # create a symlink
  FileUtils.ln_s(src, dest)
end

When /^I run the command "(.*?)" to (validate|package|clean|create) the app$/ do |cmd, _action|
  env_hash = prepare_env_hash_for(cmd)
  IO.popen(env_hash, cmd, 'w+') do |pipe|
    pipe.puts "\n"
    pipe.close_write
    @output = pipe.readlines
    @output.each { |line| puts line }
  end
end

Then /^the app file "(.*?)" is created with:$/ do |file, content|
  expect(File.read(file).chomp.gsub(' ', '')).to eq content.gsub(' ', '')
end

Then /^the app file "(.*?)" is created$/ do |filename|
  expect(File.exist?(filename)).to be_truthy
end

Then /^the fixture "(.*?)" is used for "(.*?)"$/ do |fixture, app_file|
  fixture_file = File.join('features', 'fixtures', fixture)
  app_file_path = File.join(@app_dir, app_file)

  FileUtils.cp(fixture_file, app_file_path)
end

Then /^the zip file should exist in directory "(.*?)"$/ do |path|
  expect(Dir[path + '/app-*.zip'].size).to eq 1
end

Given /^I remove file "(.*?)"$/ do |file|
  File.delete(file)
end

Then /^the zip file in "(.*?)" folder should not exist$/ do |path|
  expect(Dir[path + '/app-*.zip'].size).to eq 0
end

Then /^it should pass the validation$/ do
  expect(@output.last).to match /OK/
  expect($CHILD_STATUS).to eq 0
end

Then /^the command output should contain "(.*?)"$/ do |output|
  expect(@output.join).to match /#{output}/
end

Then /^"(.*?)" should be a symlink$/ do |path|
  expect(File.symlink?(path)).to be_truthy
end

Then /^the zip file in "(.*?)" should not contain any symlinks$/ do |path|
  Zip::File.foreach Dir[path + '/app-*.zip'][0] do |p|
    expect(p.symlink?).to be_falsy
  end
end

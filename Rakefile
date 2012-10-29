require 'rake/clean'
require 'cucumber/rake/task'

CLEAN << 'tmp'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format pretty}
end

task :default => :cucumber

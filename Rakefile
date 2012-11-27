require 'rake/clean'
CLEAN << 'tmp'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :spec

task :default => :spec

require 'bundler/gem_tasks'
require 'rake'
require 'rake/clean'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'bump/tasks'

RSpec::Core::RakeTask.new(:spec)

CLEAN << 'tmp'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w(--format progress)
end

task default: [:spec, :cucumber]

namespace :bump do
  (Bump::Bump::BUMPS + ["current", "file", "show-next"]).each do |bump|
    task (bump + ':safe') do |t|
      cmd = "bundle exec rake bump:" + bump + " " + "BUNDLE=false"
      exec(cmd)
    end
  end
end

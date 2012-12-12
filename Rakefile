require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :spec

task :default => :spec

def array_to_nested_hash(array)
  array.inject({}) do |result, item|
    keys = item['key'].split('.')
    current = result
    keys[0..-2].each do |key|
      current = (current[key] ||= {})
    end
    current[keys[-1]] = item['value']
    result
  end
end

require 'pathname'
project_root = Pathname.new(File.dirname(__FILE__))
zendesk_i18n_file = project_root.join('config/locales/en.zendesk.yml')
standard_i18n_file = project_root.join('config/locales/en.yml')

file standard_i18n_file => zendesk_i18n_file do |task|
  header = "# This is a generated file. Please do not edit it.\n"
  input = YAML.load( File.read(task.prerequisites.first) )
  translations = input['parts'].map { |part| part['translation'] }
  yaml = YAML.dump( { 'en' => array_to_nested_hash(translations) } )
  File.open(task.name, 'w') { |f| f << header + yaml }
end

namespace :i18n do

  desc 'Generate the standard I18n file'
  task :standardize => standard_i18n_file

end

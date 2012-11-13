Gem::Specification.new do |s|
  s.name        = "zendesk_apps_support"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James A. Rosen", "Kenshiro Nakagawa", "Shajith Chacko"]
  s.email       = ["dev@zendesk.com"]
  s.homepage    = "http://github.com/zendesk/zendesk_apps_support"
  s.summary     = "Support to help you develop Zendesk Apps."
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'faraday',     '~> 0.8.0'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'rubyzip',     '~> 0.9.1'
  s.add_runtime_dependency 'jshintrb',    '0.1.6'

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'

  s.files        = Dir.glob("{lib,config,template}/**/*") + %w(README.md LICENSE)
  s.test_files   = Dir.glob("features/**/*")
  s.require_path = 'lib'
end

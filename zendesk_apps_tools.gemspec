Gem::Specification.new do |s|
  s.name        = "zendesk_apps_tools"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James A. Rosen", "Kenshiro Nakagawa"]
  s.email       = ["dev@zendesk.com"]
  s.homepage    = "http://github.com/zendesk/zendesk_apps_tools"
  s.summary     = "Tools to help you develop Zendesk Apps."
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency 'faraday',     '~> 0.8.0'
  s.add_runtime_dependency 'thor',        '~> 0.15.2'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'rubyzip',     '~> 0.9.1'
  s.add_runtime_dependency 'system_timer'

  s.add_development_dependency 'ruby-debug'

  s.files        = Dir.glob("{lib,bin}/**/*") + %w(README.md LICENSE)
  s.test_files   = Dir.glob("test/**/*")
  s.require_path = 'lib'
end

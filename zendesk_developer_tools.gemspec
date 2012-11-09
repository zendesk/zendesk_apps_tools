Gem::Specification.new do |s|
  s.name        = "zendesk_developer_tools"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James A. Rosen", "Kenshiro Nakagawa", "Shajith Chacko"]
  s.email       = ["dev@zendesk.com"]
  s.homepage    = "http://github.com/zendesk/zendesk_apps_tools"
  s.summary     = "Tools to help you develop Zendesk Apps."
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency 'thor',                  '~> 0.15.2'
  s.add_runtime_dependency 'zendesk_apps_tools'

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'

  s.files        = Dir.glob("bin/**/*") + %w(README.md LICENSE)
  s.require_path = 'lib'
end

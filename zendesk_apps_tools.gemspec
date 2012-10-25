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

  s.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE)
  s.test_files   = Dir.glob("test/**/*")
  s.require_path = 'lib'
end

require_relative './lib/zendesk_apps_tools/version'

Gem::Specification.new do |s|
  s.name        = 'zendesk_apps_tools'
  s.version     = ZendeskAppsTools::VERSION
  s.executables << 'zat'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'Apache-2.0'
  s.authors     = ['James A. Rosen', 'Kenshiro Nakagawa', 'Shajith Chacko', 'Likun Liu']
  s.email       = ['dev@zendesk.com']
  s.homepage    = 'http://github.com/zendesk/zendesk_apps_tools'
  s.summary     = 'Tools to help you develop Zendesk Apps.'
  s.description = s.summary

  s.required_ruby_version = '>= 2.6'
  s.required_rubygems_version = '>= 3.0.0'

  s.add_runtime_dependency 'thor',        '~> 0.19.4'
  s.add_runtime_dependency 'rubyzip',     '>= 1.2.1', '< 2.4.0'
  s.add_runtime_dependency 'thin',        '~> 1.8.0'
  s.add_runtime_dependency 'sinatra',     '>= 1.4.6', '< 2.3.0'
  s.add_runtime_dependency 'faraday',     '~> 0.17.5'

  s.add_runtime_dependency 'execjs',      '~> 2.7.0'
  s.add_runtime_dependency 'zendesk_apps_support', '~> 4.36.0'
  s.add_runtime_dependency 'sinatra-cross_origin', '~> 0.3.1'
  s.add_runtime_dependency 'listen', '~> 2.10'
  s.add_runtime_dependency 'rack-livereload'
  s.add_runtime_dependency 'faye-websocket', '>= 0.10.7', '< 0.12.0'

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rake'


  s.files        = Dir.glob('{bin,lib,app_template*,templates}/**/*') + %w[README.md LICENSE]
  s.test_files   = Dir.glob('features/**/*')
  s.require_path = 'lib'
end

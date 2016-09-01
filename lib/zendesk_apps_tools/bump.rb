require 'thor'
require 'zendesk_apps_tools/manifest_handler'

module ZendeskAppsTools
  class Bump < Thor
    include Thor::Actions
    prepend ManifestHandler

    SHARED_OPTIONS = {
      ['commit', '-c'] => false,
      ['message', '-m'] => nil,
      ['tag', '-t'] => false
    }

    desc 'major', 'Bump major version'
    method_options SHARED_OPTIONS
    def major
      semver[:major] += 1
      semver[:minor] = 0
      semver[:patch] = 0
    end

    desc 'minor', 'Bump minor version'
    method_options SHARED_OPTIONS
    def minor
      semver[:minor] += 1
      semver[:patch] = 0
    end

    desc 'patch', 'Bump patch version'
    method_options SHARED_OPTIONS
    def patch
      semver[:patch] += 1
    end

    default_task :patch

    private

    def post_actions
      return tag if options[:tag]
      commit if options[:commit]
    end

    def commit
      `git commit -am #{commit_message}`
    end

    def commit_message
      options[:message] || version(v: true)
    end

    def tag
      commit
      `git tag #{version(v: true)}`
    end
  end
end

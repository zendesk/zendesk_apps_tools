require 'thor'
require 'json'

require 'zendesk_apps_tools/manifest_handler'

module ZendeskAppsTools
  class Bump < Thor
    include Thor::Actions
    prepend ManifestHandler

    desc 'major', 'Bump major version'
    def major
      semver[:major] += 1
      semver[:minor] = 0
      semver[:patch] = 0
    end

    desc 'minor', 'Bump minor version'
    def minor
      semver[:minor] += 1
      semver[:patch] = 0
    end

    desc 'patch', 'Bump patch version'
    def patch
      semver[:patch] += 1
    end
  end
end

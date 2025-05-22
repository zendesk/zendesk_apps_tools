# IN MAINTENANCE MODE

Zendesk Apps Tools is in maintenance mode. This means no additional feature enhancements or non-security bugs will be fixed. **We recommend switching to using [ZCLI](https://github.com/zendesk/zcli) for our best CLI experience.**


# Zendesk Apps Tools

## Description
Zendesk Apps Tools (ZAT) are a collection of local development tools that simplify building and deploying [Zendesk apps](https://developer.zendesk.com/apps/docs/apps-v2/getting_started).

## Owners
This repo is owned and maintained by the Zendesk Apps team. You can reach us on vegemite@zendesk.com. We are located in Melbourne.

## Install and use ZAT
ZAT is a Ruby gem. You don't need to know Ruby to use the tools but you do need to install Ruby to install the gem.

To install, run `gem install zendesk_apps_tools`.

To get the latest version, run `gem update zendesk_apps_tools`.

For information on using the tools, see  [Zendesk App Tools](https://developer.zendesk.com/apps/docs/developer-guide/zat) on developer.zendesk.com.

## Work on ZAT
If you want to help **develop** this tool, clone this repo and run `bundle install`.

If you receive this error:
    Installing nokogiri 1.10.10 with native extensions
    Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
Then run `gem install nokogiri -- --use-system-libraries` followed by run `bundle config build.nokogiri --use-system-libraries` and try running `bundle install` again.

ZAT uses a gem called [ZAS](https://github.com/zendesk/zendesk_apps_support/). If you're developing ZAT, you'll probably want to edit code in ZAS too. To do so, you need to clone the ZAS repo and add the following line at the end of `Gemfile` in the ZAT project:

`gem 'zendesk_apps_support', path: '../zendesk_apps_support'`

Then, comment-out the line referring to `zendesk_apps_support` in this project's `.gemspec` file.

```
# s.add_runtime_dependency 'zendesk_apps_support', '~> X.YY.ZZ'
```

The path should point to your local ZAS directory. In this way, your clone of ZAT will use a local version of ZAS, which is very helpful for development. Run a `bundle install` after changing the Gemfile.

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. run `bundle lock` to update `Gemfile.lock`,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/zendesk_apps_tools/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/zendesk_apps_tools/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

## Testing
This project uses rspec, which you can run with `bundle exec rake`.

## Contribute
Improvements are always welcome. To contribute:

* Put up a PR into the master branch.
* CC and get two +1 from @zendesk/vegemite.

This repo contains the ZAT documentation published on the developer portal at https://developer.zendesk.com. Please cc **@zendesk/documentation** on any PR that adds or updates the documentation.

## Bugs
You can report bugs as issues here on GitHub. You can also submit a bug to support@zendesk.com. Mention "zendesk_apps_tools" in the ticket so it can be assigned to the right team.

# Copyright and license
Copyright 2013 Zendesk
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

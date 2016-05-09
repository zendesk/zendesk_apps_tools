# Zendesk Apps Tools

## Description
Zendesk Apps Tools (ZAT) is the only tool needed for developing Zendesk Apps. It makes it easy to develop [Zendesk Apps](http://developer.zendesk.com/documentation/apps/). We have a [guide](http://developer.zendesk.com/documentation/apps/reference/tools.html) that explains how to use this tool.

## Owners
This repo is owned and maintained by the Zendesk Apps team. You can reach us on vegemite@zendesk.com. We are located in Melbourne!

## Getting Started To **Use** ZAT
If you want to **use** this tool, all you need to do is `gem install zendesk_apps_tools` and periodically run `gem update zendesk_apps_tools` because we will keep updating this tool.

## Getting Started To **Develop** ZAT
When you want to help **develop** this tool, you will need to clone this repo and run `bundle install` to get it going.

ZAT uses a gem called [ZAS](https://github.com/zendesk/zendesk_apps_support/). In the case you are developing ZAT, it is likely you might want to edit code in ZAS too, which means you will need to clone ZAS too and change the `Gemfile` 9in the ZAT project) to say `gem 'zendesk_apps_support' path: '../zendesk_apps_support'`. The path should point to your local ZAS directory. This way your clone of ZAT will use a local version of ZAS which is very helpful for development. Run a `bundle install` after changing the Gemfile.

## Testing
This project uses rspec, which can be run with `bundle exec rake`.

## Contribute
Improvements are always welcome. To contribute, please:

* Put up a PR into the master branch.
* CC and get two +1 from @zendesk/vegemite.

## Bugs
Bugs can be reported as an issue here on github, or submitted to support@zendesk.com. By mentioning this project it will assigned to the right team.

# Copyright and license
Copyright 2013 Zendesk
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

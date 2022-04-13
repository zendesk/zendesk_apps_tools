FROM ruby:2.6

COPY . /usr/src/app
WORKDIR /usr/src/app
RUN gem install bundler
RUN bundle install
RUN gem build zendesk_apps_tools.gemspec
RUN gem install zendesk_apps_tools-*.gem
EXPOSE 4567
ENTRYPOINT [ "zat" ]

FROM ruby:2.6

COPY . /usr/src/app
WORKDIR /usr/src/app
RUN gem install bundler
RUN bundle install

ENTRYPOINT [ "./bin/zat" ]

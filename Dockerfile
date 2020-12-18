FROM ruby:2.7.1-alpine

WORKDIR /tmp

RUN apk --update --no-cache add libxml2-dev libxslt-dev libstdc++ tzdata ca-certificates bash npm yarn \
    shadow sudo busybox-suid tzdata alpine-sdk libxml2-dev curl-dev postgresql-dev file file-dev vim

WORKDIR /usr/src/app

ADD Gemfile Gemfile.lock ./
RUN gem install bundler --no-document && \
    bundle update --bundler && \
    bundle install

ADD ./ /usr/src/app

CMD bundle exec rails s -p 3000 -b 0.0.0.0

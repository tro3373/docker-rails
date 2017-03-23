FROM ruby:2.4.0
# Rails console 上で日本語入力できるように ENV LANG C.UTF-8 を指定
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client nodejs
RUN gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=$APP_HOME/vendor/bundle/


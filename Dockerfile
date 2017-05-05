FROM ruby:2.4.0
# Rails console 上で日本語入力できるように ENV LANG C.UTF-8 を指定
ENV LANG C.UTF-8

# Install newer nodejs(version 7.x) for yarn
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y \
        build-essential \
        libpq-dev \
        postgresql-client \
        nodejs \
        apt-transport-https
RUN node -v

# Install yarn
# GPG for yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# https use apt-transport-https package.
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
        && apt-get install -y yarn

# Install bundler
RUN gem install bundler
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=$APP_HOME/vendor/bundle/

# Application Setting
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME


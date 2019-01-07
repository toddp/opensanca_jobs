FROM ruby:2.5.0-alpine

LABEL maintainer="opensanca@opensanca.com"

ARG rails_env="development"
ARG build_without=""

RUN apk update \
  && apk add \
    openssl \
    tar \
    build-base \
    tzdata \
    postgresql-dev \
    postgresql-client \
    nodejs \
  && wget https://yarnpkg.com/latest.tar.gz \
  && mkdir -p /opt/yarn \
  && tar -xf latest.tar.gz -C /opt/yarn --strip 1 \
  && mkdir -p /var/app

ARG secret_key_base
ENV SECRET_KEY_BASE=$secret_key_base
ENV PATH="$PATH:/opt/yarn/bin" BUNDLE_PATH="/gems" BUNDLE_JOBS=2 RAILS_ENV=${rails_env} BUNDLE_WITHOUT=${bundle_without} SECRET_KEY_BASE="$(rake secret)"

COPY . /var/app
WORKDIR /var/app

RUN bundle install && yarn && bundle exec rake assets:precompile
CMD rails s -b 0.0.0.0

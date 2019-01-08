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

ENV LIBV8_VERSION 3.16.14.18



ARG secret_key_base
ENV SECRET_KEY_BASE=$secret_key_base
ENV PATH="$PATH:/opt/yarn/bin"
#ENV BUNDLE_PATH="/gems"
ENV BUNDLE_JOBS=2
ENV RAILS_ENV=${rails_env}
ENV BUNDLE_WITHOUT=${bundle_without}
ENV SECRET_KEY_BASE="$(rake secret)"

COPY . ./var/app
WORKDIR /var/app
RUN apk --update --no-cache add --virtual build-deps build-base python postgresql-dev nodejs g++; \
  bundle config build.libv8 --enable-debug && \
  LIBV8_VERSION=$LIBV8_VERSION bundle install --without development test && apk del build-deps

#RUN bundle install
RUN /opt/yarn/bin/yarn install
RUN bundle exec rake assets:precompile RAILS_ENV=production
CMD bundle exec rails s -b 0.0.0.0
#CMD top

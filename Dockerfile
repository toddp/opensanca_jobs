FROM starefossen/ruby-node
LABEL maintainer="opensanca@opensanca.com"

ARG rails_env="development"
ARG build_without=""

ENV LIBV8_VERSION 3.16.14.18



ARG secret_key_base
ENV SECRET_KEY_BASE=$secret_key_base
ENV PATH="$PATH:/opt/yarn/bin"
#ENV BUNDLE_PATH="/gems"
ENV BUNDLE_JOBS=2
ENV RAILS_ENV=${rails_env}
ENV BUNDLE_WITHOUT=${bundle_without}
ENV SECRET_KEY_BASE="$(rake secret)"

COPY . /var/app
WORKDIR /var/app
#RUN apt-get -y update --no-cache install --virtual build-deps build-base python postgresql-dev nodejs g++; \
#  bundle config build.libv8 --enable-debug && \
#  LIBV8_VERSION=$LIBV8_VERSION bundle install --without development test

RUN bundle install
RUN npm install node-sass@latest
#RUN yarn install
RUN bundle exec rake webpacker:compile
RUN bundle exec rake assets:precompile --trace RAILS_ENV=production
CMD bundle exec rails s -b 0.0.0.0
#CMD top

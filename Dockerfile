# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.0.6
FROM ruby:${RUBY_VERSION}-bullseye AS base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# ===========================================================
# BUILD STAGE
# ===========================================================
FROM base AS build

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libvips \
      libmariadb-dev \
      libmariadb-dev-compat \
      pkg-config \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Atualiza Bundler globalmente
RUN gem uninstall -aIx bundler && \
    gem install bundler:2.4.22 && \
    bundle config set --global frozen 'false'

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

COPY . .

# Pré-compila os assets (sem bootsnap)
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ===========================================================
# RUNTIME STAGE
# ===========================================================
FROM base

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
      libvips \
      libmariadb-dev \
      libmariadb-dev-compat \
      curl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE 3000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server"]

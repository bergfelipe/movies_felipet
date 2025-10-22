# syntax = docker/dockerfile:1

# ===========================================================
# 🎬 Movies Felipet - Dockerfile otimizado e compatível com Render
# ===========================================================

ARG RUBY_VERSION=3.0.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# ===========================================================
# 🔨 Fase de build
# ===========================================================
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libmysqlclient-dev \
    git \
    libvips \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ===========================================================
# 🚀 Fase final
# ===========================================================
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libmysqlclient-dev \
    libvips \
    curl \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE 3000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["./bin/rails", "server"]

# syntax = docker/dockerfile:1

# ===========================================================
# 🎬 Movies Felipet - Dockerfile otimizado para Render
# ===========================================================

# Versão do Ruby (garanta que bate com a do Gemfile e .ruby-version)
ARG RUBY_VERSION=3.0.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Diretório da aplicação
WORKDIR /rails

# Ambiente de produção
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# ===========================================================
# 🔨 Fase de build (compila gems e assets)
# ===========================================================
FROM base as build

# Instala dependências para build e MySQL client
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    libvips \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copia dependências Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia o código da aplicação
COPY . .

# Precompila código e assets para produção
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ===========================================================
# 🚀 Fase final (imagem de produção)
# ===========================================================
FROM base

# Instala apenas dependências necessárias em runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    default-mysql-client \
    libvips \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia artefatos do build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Configura o usuário não-root (segurança)
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Expõe a porta padrão do Puma
EXPOSE 3000

# Entrypoint padrão (migra DB automaticamente se precisar)
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Comando padrão do container
CMD ["./bin/rails", "server"]

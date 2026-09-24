# syntax=docker/dockerfile:1

# Debian 13.
FROM ruby:3.4.11-slim-trixie AS os

RUN rm -f /etc/apt/apt.conf.d/docker-clean \
 && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
 && apt-get install --yes --no-install-recommends \
      nodejs \
      build-essential \
      libpq-dev \
      wget \
      libjpeg62-turbo \
      libpng16-16t64 \
      libxrender1 \
      libfontconfig1 \
      libfreetype6 \
      libx11-6 \
      libyaml-dev \
      procps

WORKDIR /ziher

FROM os AS gems

COPY Gemfile Gemfile.lock ./

RUN gem install bundler --version 2.6.7 --no-document

# Shared gems only. Dev and prod add their own groups so a local build
# does not compile Passenger, and a prod build does not install test gems.
ENV BUNDLE_WITHOUT="development:test:production"

# The wkhtmltopdf-binary wrapper picks a binary from /etc/os-release and has
# no entry for Debian 13, so name the one to use. The Debian 12 builds link
# against libssl3, which Trixie ships, and exist for amd64 and arm64.
ARG TARGETARCH
ENV WKHTMLTOPDF_HOST_SUFFIX=debian_12_${TARGETARCH}

# Unpack the wkhtmltopdf binary once (the container may run read-only) and
# drop the other ~430 MB of archives in the same layer they were installed.
RUN --mount=type=cache,target=/usr/local/bundle/cache \
    set -eu; \
    bundle install; \
    for bindir in /usr/local/bundle/gems/wkhtmltopdf-binary-*/bin; do \
      gunzip "$bindir/wkhtmltopdf_${WKHTMLTOPDF_HOST_SUFFIX}.gz"; \
      chmod 755 "$bindir/wkhtmltopdf_${WKHTMLTOPDF_HOST_SUFFIX}"; \
      rm -f "$bindir"/*.gz; \
    done; \
    wkhtmltopdf --version

FROM gems AS dev

ENV RAILS_ENV=development
ENV BUNDLE_WITHOUT=production

RUN --mount=type=cache,target=/usr/local/bundle/cache \
    bundle install

COPY . /ziher

ENTRYPOINT ["/bin/bash", "/ziher/docker/entrypoint-dev.sh"]

FROM gems AS prod

ENV RAILS_ENV=production \
    RAILS_RELATIVE_URL_ROOT=/ \
    BUNDLE_WITHOUT="development:test"

RUN --mount=type=cache,target=/usr/local/bundle/cache \
    bundle install

COPY . /ziher

# No SECRET_KEY_BASE is baked into the image. The runtime must provide it,
# otherwise Rails refuses to boot in production.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile --trace

ENTRYPOINT ["passenger", "start", "-p", "3000", "-a", "0.0.0.0"]

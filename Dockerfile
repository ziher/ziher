FROM ruby:2.5.9-stretch

ENV RAILS_RELATIVE_URL_ROOT=/
ENV RAILS_ENV=production

SHELL ["/bin/bash", "-c"]

RUN mkdir /ziher
WORKDIR /ziher
COPY Gemfile /ziher/Gemfile
COPY Gemfile.lock /ziher/Gemfile.lock
RUN set -x \
  && gem install bundler \
  && bundle config set --local without 'development test' \
  && bundle install --no-cache \
  && rm -rf /usr/local/bundle/cache/* \
  && source /etc/os-release \
  && gunzip /usr/local/bundle/gems/wkhtmltopdf-binary-*/bin/wkhtmltopdf_debian_${VERSION_ID}_amd64.gz \
  && rm -rf /usr/local/bundle/gems/wkhtmltopdf-binary-*/bin/*.gz

RUN set -x \
 && apt-get update \
 && apt-get upgrade --yes \
 && apt-get install --yes \
      build-essential \
      libpq-dev \
      \
 && apt-get --yes --purge autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY config/initializers/version.rb /ziher/config/initializers/version.rb
COPY . /ziher

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE ${SECRET_KEY_BASE}

RUN set -x \
 && rake assets:precompile --trace

ENTRYPOINT ["passenger", "start", "-p", "3000", "-a", "0.0.0.0"]

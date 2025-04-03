FROM ziher/base:2025.04.02-30b4eab AS ziher-prod

SHELL ["/bin/bash", "-c"]

ENV RAILS_RELATIVE_URL_ROOT=/
ENV RAILS_ENV=production

COPY Gemfile /ziher/Gemfile
COPY Gemfile.lock /ziher/Gemfile.lock
COPY config/initializers/version.rb /ziher/config/initializers/version.rb
COPY . /ziher

RUN set -x \
  && bundle config set --local without 'development test' \
  && bundle install --no-cache \
  && rm -rf /usr/local/bundle/cache/* \
  && gunzip /usr/local/bundle/gems/wkhtmltopdf-binary-*/bin/wkhtmltopdf_debian_11_amd64.gz \
  && rm -rf /usr/local/bundle/gems/wkhtmltopdf-binary-*/bin/*.gz \
  && chmod 100 /usr/local/bundle/gems/wkhtmltopdf-binary-0.12.6.8/bin/wkhtmltopdf_debian_11_amd64

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

RUN set -x \
 && rake assets:precompile --trace

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

ENTRYPOINT ["passenger", "start", "-p", "3000", "-a", "0.0.0.0"]

# ##########################
# ##########################
FROM ziher-prod AS ziher-dev

ENV RAILS_ENV=development

RUN set -x \
  && bundle config unset --local without \
  && bundle install

ENTRYPOINT ["/bin/bash", "-c"]

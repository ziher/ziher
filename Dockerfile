FROM ruby:2.4.2

ENV RAILS_RELATIVE_URL_ROOT=/
ENV RAILS_ENV=production

RUN mkdir /ziher
WORKDIR /ziher
COPY Gemfile /ziher/Gemfile
COPY Gemfile.lock /ziher/Gemfile.lock
RUN gem install bundler && bundle install

COPY config/initializers/version.rb /ziher/config/initializers/version.rb
COPY . /ziher
RUN rake assets:precompile --trace

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
      build-essential \
      libpq-dev \
      && \
    apt-get --yes --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["passenger", "start", "-p", "3000", "-a", "0.0.0.0"]

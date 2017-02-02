FROM ruby:2.3.1

ENV RAILS_RELATIVE_URL_ROOT=/
ENV RAILS_ENV=production

RUN mkdir /ziher
WORKDIR /ziher
COPY Gemfile /ziher/Gemfile
COPY Gemfile.lock /ziher/Gemfile.lock
RUN bundle install

COPY config/initializers/version.rb /ziher/config/initializers/version.rb
COPY . /ziher
RUN rake assets:precompile --trace

RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT passenger start -p 3000 -a 0.0.0.0

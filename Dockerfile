FROM ruby:2.1.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /ziher
WORKDIR /ziher
ADD Gemfile /ziher/Gemfile
ADD Gemfile.lock /ziher/Gemfile.lock
RUN bundle install
ADD . /ziher

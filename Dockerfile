FROM ruby:2.1.2
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev

RUN mkdir /ziher
WORKDIR /ziher
COPY Gemfile /ziher/Gemfile
COPY Gemfile.lock /ziher/Gemfile.lock
RUN bundle install

COPY . /ziher
RUN rake assets:precompile --trace RAILS_ENV=production

ENTRYPOINT passenger start -p 3000 -a 0.0.0.0

# Very, very, very bad hack for Passenger giving errors I don't care about (as for now)
RUN ln /bin/echo /bin/ps

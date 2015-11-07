#RUN apt-get update && apt-get install -y \
  #build-essential \
  #libpq-dev
#
#RUN mkdir /ziher
#WORKDIR /ziher
#COPY Gemfile /ziher/Gemfile
#COPY Gemfile.lock /ziher/Gemfile.lock
#RUN bundle install
#
#COPY . /ziher
#RUN rake assets:precompile --trace RAILS_ENV=production


# https://github.com/phusion/passenger-docker#getting-started
# https://github.com/phusion/passenger-docker/blob/master/Changelog.md
FROM phusion/passenger-ruby21:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down
# Remove the default site
RUN rm /etc/nginx/sites-enabled/default
# Add the nginx info
COPY nginx.conf /etc/nginx/sites-enabled/webapp.conf

WORKDIR /tmp
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY . /home/app
WORKDIR /home/app
RUN rake assets:precompile --trace RAILS_ENV=production

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

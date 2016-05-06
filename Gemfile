source 'http://rubygems.org'

ruby "2.3.1"

gem 'rails', '3.2.22'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'

group :development, :test do
  gem 'time-warp'
end

group :development do
  gem 'bullet'
end

# production is set on Heroku right now which needs PostgreSQL
group :production do
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  gem 'therubyracer'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails', '2.2.8'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'acts_as_list'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'
gem 'passenger'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem "turn", "~> 0.9.6", :require => false
  #gem "minitest", "~> 5.0.7"
end

gem 'rails-i18n'

gem 'devise', '~> 2.2.5'
gem 'devise-i18n'
gem 'devise_invitable', '1.1.2'

gem 'cancan'

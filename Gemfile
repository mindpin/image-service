# source 'https://rubygems.org'
source 'http://ruby.taobao.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # test

  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.2.1'
  gem 'shoulda'
  gem 'shoulda-matchers', require: false
end

# 以下是根据需要手动增加的
gem "mongoid", "4.0.0"
gem 'figaro', '>= 1.0.0'

gem 'devise'
gem "omniauth-weibo-oauth2"
gem "omniauth-qq"
gem "haml"
gem 'kaminari'

# enum
gem 'enumerize'
gem 'qiniu', '~> 6.4.1'
# image
gem "carrierwave", "0.8.0"
gem 'carrierwave-mongoid'
gem "mini_magick"
gem "sidekiq"

gem "unicorn", group: :production
gem "mina",
    :git => "git://github.com/fushang318/mina.git",
    :tag => "v0.2.0fix"

group :test do
  gem "database_cleaner", "~> 1.4.0"
end

group :development do
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec', require: false
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

gem "non-stupid-digest-assets"
gem "rails_admin"

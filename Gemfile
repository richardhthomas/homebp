source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Allows jquery event handlers to still bind to DOM objects when Turbolinks is used.
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise', '~>3.0.0.rc'

gem 'dynamic_form'

# needed by Heroku
group :production, :staging do
  gem 'rails_12factor'
end
ruby "2.0.0"
# gem 'rails_12factor', group: :production

# use postgresql
gem 'pg'

# use unicorn as webserver
gem 'unicorn'

# use postmark for email
gem 'postmark-rails'

# use active_attr gem - this allows you to operate on model objects without them having to be backed by a database 
gem 'active_attr'

# needed to store session in db rather than in cookies
gem 'activerecord-session_store'

# provides a package of security features
gem 'secure_headers'

# mixpanel
gem 'mixpanel-ruby'

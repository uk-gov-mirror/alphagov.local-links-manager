ruby File.read('.ruby-version').strip
source 'https://rubygems.org'


if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 30.2'
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'gds-sso', '~> 12.0'
gem 'govuk_admin_template', '~> 4.2'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

gem 'pg'

# Provides breadcrumbs, see config/breadcrumbs.rb
gem 'gretel', '3.0.8'

gem 'addressable'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end


gem 'unicorn', '~> 4.9.0'
gem 'logstasher', '0.6.2'
group :development, :test do
  gem 'capybara', '~> 2.7'
  gem 'factory_girl_rails', '~> 4.7'
  gem 'rspec-rails', '~> 3.3'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
end

group :test do
  gem 'webmock', '~> 1.2'
end

gem 'plek', '~> 1.10'
gem 'airbrake', '~> 4.2.1'
gem 'govuk-lint'

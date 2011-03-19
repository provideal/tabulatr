source 'http://rubygems.org'

gemspec

group :development, :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  if RUBY_VERSION.to_f < 1.9
    gem 'ruby-debug'
  else
    gem 'ruby-debug19'
  end
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
end

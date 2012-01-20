ENV["RAILS_ENV"] ||= 'test'

require File.expand_path('../dummy_app/config/environment', __FILE__)
ActiveRecord::Migrator.migrate File.expand_path("../dummy_app/db/migrate/", __FILE__)

require 'rspec/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_examples = true
  DatabaseCleaner.strategy = :transaction
end

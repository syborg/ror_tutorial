require 'test_helper'

# MME Enable this to use capybara

# require 'capybara/rails'
# require 'database_cleaner'

# # Transactional fixtures do not work with Selenium tests, because Capybara
# # uses a separate server thread, which the transactions would be hidden
# # from. We hence use DatabaseCleaner to truncate our test database.
# DatabaseCleaner.strategy = :truncation

# class ActionDispatch::IntegrationTest
#   # Make the Capybara DSL available in all integration tests
#   include Capybara::DSL

#   # Stop ActiveRecord from wrapping tests in transactions
#   self.use_transactional_fixtures = false

#   teardown do
#     DatabaseCleaner.clean       # Truncate the database
#     Capybara.reset_sessions!    # Forget the (simulated) browser state
#     Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
#   end
# end

# MME Enable this to use webrat

require "webrat"
require 'webrat/core/matchers'

include Webrat::Methods

Webrat.configure do |config|
  config.mode = :rack
end
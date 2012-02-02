require 'test_helper'

# MME Enable this to use capybara

require 'capybara/rails'

class ActionDispatch::IntegrationTest

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

end

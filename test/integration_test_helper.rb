require 'test_helper'

# MME Enable this to use capybara

require 'capybara/rails'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  def integration_signin
  	Capybara.current_driver = Capybara.javascript_driver # :selenium by default
    attribs = {:name=>"usuari", :email=>"usuari@integration.net",
               :password=>"collonets", :password_confirmation=>"collonets"}
    @user=User.create(attribs)
    @user.activate
    visit signin_path
    fill_in 'session_email',    :with => @user.email
    fill_in 'session_password', :with => "collonets"
    click_button "Sign in"
  end

end

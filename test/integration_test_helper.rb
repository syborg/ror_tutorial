require 'test_helper'

# MME Enable this to use capybara

require 'capybara/rails'

class ActionDispatch::IntegrationTest

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  def integration_signin(user)
    visit signin_path
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button "Sign in"
  end

end

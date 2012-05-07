require 'integration_test_helper'

class FriendlyForwardingTest < ActionDispatch::IntegrationTest

  fixtures :all

  context "FriendlyForwardings" do

    setup do
      #Capybara.current_driver = Capybara.javascript_driver
      @attr = {email: "test@email.tst",  password: "testpwd"}
      @user=User.create! @attr.merge({name: "test_user", password_confirmation: "testpwd"})
      @user.activate  # force @user to be already activated
    end

    should "forward to the requested page after signin" do
      visit edit_user_path(@user)
      # The test automatically follows the redirect to the signin page.
      fill_in 'session_email',    :with => @attr[:email]
      fill_in 'session_password', :with => @attr[:password]
      click_button "Sign in"
      # The test follows the redirect again, this time to users/edit.
      assert page.has_selector?("h1", :text => "Editing user"), "not 'Editing User' header"
      assert page.has_field?("user_name"), "no user_name field"
    end
  end
end

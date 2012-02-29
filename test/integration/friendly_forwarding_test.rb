require 'integration_test_helper'

class FriendlyForwardingTest < ActionDispatch::IntegrationTest

  fixtures :all

  context "FriendlyForwardings" do

    setup do
      @attr = {email: "test@email.tst",  password: "testpwd"}
      @user=User.create! @attr.merge({name: "test_user", password_confirmation: "testpwd"})
    end

    should "forward to the requested page after signin" do
      visit edit_user_path(@user)
      # The test automatically follows the redirect to the signin page.
      fill_in :email,    :with => @attr[:email]
      fill_in :password, :with => @attr[:password]
      click_button "Sign in"
      # The test follows the redirect again, this time to users/edit.
      assert page.has_field?("h1", :with => "Editing user"), "is not edit page"
    end
  end
end

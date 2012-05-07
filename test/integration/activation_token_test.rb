require 'integration_test_helper'

class ActivationTokensTest < ActionDispatch::IntegrationTest

  fixtures :all

  setup do
     Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  context "a user with activation token" do

    setup do
      @attr={:name=>"Bartomeu",
            :email=>"barty@pelacanyes.cat",
            :password=>"bartomine",
            :password_confirmation=>"bartomine"}
      @user=User.create @attr
      @pr=@user.generate_activation_token
    end

    should "not be able to signin if not activated" do
      visit signin_path
      fill_in 'session_email',    :with => @attr[:email]
      fill_in 'session_password', :with => @attr[:password]
      click_button "Sign in"
      assert page.has_selector?("div.flash", :text => "Activate your account")
    end

    should "be able to sign in if activated account" do
      visit activate_user_path(@pr.token)
      fill_in 'session_email',    :with => @attr[:email]
      fill_in 'session_password', :with => @attr[:password]
      click_button "Sign in"
      assert page.has_selector?("div.flash.success"), "Welcome not found!"
    end

  end


end

require 'integration_test_helper'

class PasswordRemindersTest < ActionDispatch::IntegrationTest

  fixtures :all

  setup do
    Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  context "when requesting a password reminder" do

    setup do
      @user=users(:one)
    end

    should "send password reminder to actual user" do
      visit signin_path
      click_link "Get your password reminder!"
      fill_in 'password_reminder_email', :with => @user.email
      click_button "Send!"
      assert page.has_selector? "div.flash", :text=>"Password Reminder sent to #{@user.email}! check it soon."
    end

    should "not send password reminder to wrong user" do
      visit signin_path
      click_link "Get your password reminder!"
      fill_in 'password_reminder_email', :with => "wrong@email.com"
      click_button "Send!"
      assert page.has_selector? "div.flash", :text=>"User doesn't exist!"
    end

  end

  context "with a password reminder" do

    setup do
      @user=users(:one)
      @pr=@user.generate_password_reminder
    end

    should "update password when correct password input" do
      visit edit_password_reminder_path(@pr.token)
      fill_in 'user_password', :with=>"new_password"
      fill_in 'user_password_confirmation', :with=>"new_password"
      click_button "Set Password!"
      assert page.has_selector? "div.flash", :text=>"Password updated"
    end

    should "not update password when wrong password input" do
      visit edit_password_reminder_path(@pr.token)
      fill_in 'user_password', :with=>"new_password"
      fill_in 'user_password_confirmation', :with=>"bad_password"
      click_button "Set Password!"
      assert page.has_selector? "div.error", :text=>"Password doesn't match confirmation"
    end

    should "redirect to root when wrong password reminder" do
      visit edit_password_reminder_path("wrongreminder")
      assert page.has_selector? "div.flash", :text=>"Password Reminder is not valid"
    end

  end


end
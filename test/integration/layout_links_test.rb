require 'integration_test_helper'

class LayoutLinksTest < ActionDispatch::IntegrationTest

  fixtures :all

  context "Layout Links" do

    context "when not signed in" do

      should "have a signin link" do
        visit root_path
        assert (page.has_link? "Sign in")
      end

    end

    context "when signed in" do

      setup do
        @attr = {email: "test@email.tst",  password: "testpwd"}
        @user=User.create! @attr.merge({name: "test_user", password_confirmation: "testpwd"})
        @user.activate  # force user to be alreadi active
        visit signin_path
        fill_in 'session_email', :with=>@user.email
        fill_in 'session_password', :with=>@user.password
        click_button 'Sign in'
      end

      should "have a signout link" do
        visit root_path
        assert (page.has_link? "Sign out")
      end

    end

  end

end

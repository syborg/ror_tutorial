require 'integration_test_helper'

class UsersTest < ActionDispatch::IntegrationTest

  fixtures :all

  context "signup" do

    context "failure" do

      setup do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      should "not make a new user" do
        assert_no_difference 'User.count' do
          post_via_redirect "users", :user =>@attr  # enviem les dades d'un nou usuari via create (POST /users)
          assert_template 'users/new'     # ens retorna a users/new, que significa que no s'ha creat l'usuari
          assert_select "div#error_explanation" # comprovem que conte missatges d'error
        end
      end

      should "not make a new user (capybara)" do
        assert_no_difference 'User.count' do
          visit '/signup'
          fill_in 'Name', :with => @attr[:name]
          fill_in 'Email', :with => @attr[:email]
          fill_in 'Password', :with => @attr[:password]
          fill_in 'Confirmation', :with => @attr[:password_confirmation]
          click_button 'Sign Up!'
          #assert_equal current_path, '/users/new'  # ens retorna a users/new, que significa que 
          #assert_template 'users/new'    no s'ha creat l'usuari
          assert page.has_selector?("div#error_explanation") # comprovem que conte missatges d'error
        end
      end

    end

    context "success" do

      setup do
        @attr = { :name => "pep", :email => "fitxia@gmail.com", :password => "cuionets", :password_confirmation => "cuionets" }
      end

      should "make a new user" do
        assert_difference 'User.count', 1 do
          post_via_redirect "users", :user=>@attr
          assert_template 'sessions/new'
          assert_select "div.flash.success", :text=>/.*T'hem enviat un mail per activar.*/
        end
      end
    end
  end

  context "sign in/out" do

    context "failure" do

      setup do
        visit signin_path
        fill_in 'session_email',    :with => "wrong@email.com"
        fill_in 'session_password', :with => "wrong"
        click_button "Sign in"
      end

      should "not sign a user in" do
        assert page.has_selector?("div.flash", :text => "Invalid")
      end

    end

    context "success" do

      setup do
        integration_signin
      end

      should "sign a user in and out" do
        assert page.has_selector?("div.flash.success"), "Welcome not found!"
        click_link "Sign out"
        assert page.has_selector?("div.flash", :text => "Bye Babe"), "Bye Babe not found!"
      end

    end

  end

end

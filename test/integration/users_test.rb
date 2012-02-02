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
          assert_template 'users/new'     # ens retorna a users/new, que significa que no s'ha creat l'usuari
          assert_select "div#error_explanation" # comprovem que conte missatges d'error
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
          assert_template 'users/show'
          assert_select "div.flash.success", :content=>'welcome'
        end
      end

    end

  end

end

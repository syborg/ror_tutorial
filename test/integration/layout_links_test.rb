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
        visit signin_path
        fill_in :email, :with=>@user.email
        fill_in :password, :with=>@user.password
        click_button 'Sign in'
      end

      should "have a signout link" do
        visit root_path
        assert (page.has_link? "Sign out")
      end

    end

  end



  # MME default generated tests

  # test "should have Home page at '/'" do
  #   get '/'
  #   assert_select "title", :text=>/.*Home$/
  # end

  # test "should have Contact page at '/contact'" do
  #   get '/contact'
  #   assert_select "title", :text=>/.*Contact$/
  # end

  # test "should have About page at '/about'" do
  #   get '/about'
  #   assert_select "title", :text=>/.*About$/
  # end

  # test "should have Help page at '/help'" do
  #   get '/help'
  #   assert_select "title", :text=>/.*Help$/
  # end

  # test "should have the right links on the layout" do
  #   get root_path
  #   assert_response :success
  #   assert_select 'title', :text=>/.*Home$/
    
  #   # Comprovem que el nombre de links total al menu i al footer
  #   assert_select 'nav ul li', 7

  # end

end

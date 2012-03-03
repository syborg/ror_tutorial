require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  
  setup do
    @base_title = "Ruby on Rails Tutorial Sample App | "
  end

  context "GET 'home'" do

    context "signed in" do

      setup do
        @user=users(:one)
        test_sign_in(@user)
      end

      context "admin users" do

        setup do
          @user.toggle!(:admin)
        end

        should "show the user's microposts count" do
          get :home
          cnt = @user.microposts.count
          unit = cnt==1 ? "micropost": "microposts"
          text = "#{cnt} #{unit}"
          assert_select("span.microposts", :text => text)
        end
      end
    end

  end


  test "should get home" do
    get :home
    assert_response :success
  end

  test "home should have the right title" do
    get :home
    assert_select "title", @base_title+"Home"
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

  test "contact should have the right title" do
    get :contact
    assert_select "title", @base_title+"Contact"
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "about should have the right title" do
    get :about
    assert_select "title", @base_title+"About"
  end

  test "should get help" do
    get :help
    assert_response :success
  end

  test "help should have the right title" do
    get :help
    assert_select "title", @base_title+"Help"
  end

end

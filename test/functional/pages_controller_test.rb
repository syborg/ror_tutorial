require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "home should have the right title" do
    get :home
    assert_select "title", "Ruby on Rails Tutorial Sample App | Home"
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

  test "contact should have the right title" do
    get :contact
    assert_select "title", "Ruby on Rails Tutorial Sample App | Contact"
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "about should have the right title" do
    get :about
    assert_select "title", "Ruby on Rails Tutorial Sample App | About"
  end

end

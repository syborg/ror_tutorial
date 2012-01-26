require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "new should have the right title" do
    get :new
    assert_select "title", :text=>/.*Sign Up$/
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: @user.attributes
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user.to_param, user: @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user.to_param
    end

    assert_redirected_to users_path
  end

  # MME nous tests

  test "should create a new instance given attributes" do
    assert User.create :name=>"User Example",:email=>"user_example@email.com"
  end

  test "should require a name" do
    user = User.new(:name => "", :email => "mhartl@example.com")
    assert ! user.save, "name buid"
  end

  test "should require a mail address" do
    user = User.new(:name => "pepe", :email => "")
    assert ! user.save, "email buid"
  end

  test "should not have a long name" do
    user = User.new(:name => "a" * 51, :email => "mhartl@example.com")
    assert ! user.save, "name massa llarg"
  end

  test "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      user = User.new(:name => "pepe",:email => address)
      assert user.save, "#{address} not accepted"
    end
  end

  test "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      user = User.new(:name => "pepe",:email => address)
      assert ! user.save, "#{address} accepted"
    end
  end

  test "should reject duplicate email addresses" do
    attr = {:name => "pep", :email => "pep@gmail.com"}
    User.create! attr
    user = User.new(attr)
    assert ! user.save, "email duplicated"
  end

  test "should reject email addresses identical up to case" do
    attr = {:name => "pep", :email => "pep@gmail.com"}
    User.create! attr.merge(:email => "pep@gmail.com".upcase)
    user = User.new(attr)
    assert ! user.save, "email duplicated"
  end

end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "GET 'new'" do

    should "be successful" do
      get 'new'
      assert_response :success
    end
    
    should "have the right title" do
      get 'new'
      assert_select "title", :text=>/.*Sign Up$/
    end
    
  end

  context "GET 'show'" do

    setup do
      @user = users(:one) # MME introdueix a @users la entrada :one que hi ha a la fixture users.yml
    end

    should "be successful" do
      get :show, :id => @user
      assert_response :success
    end

    should "find the right user" do
      get :show, :id => @user
      assert_equal @user, assigns(:user)  # MME assigns es un hash que conte les instance variables del controller que arriven al view
    end

    should "have the right title" do
      get :show, :id => @user
      assert_select "title", :content => @user.name
    end

    should "include the user's name" do
      get :show, :id => @user
      assert_select "h1", :content => @user.name
    end

    should "have a profile image" do
      get :show, :id => @user
      assert_select "h1>img", :class => "gravatar"
    end
        
  end

  context "POST 'create'" do

    context "failure" do
      
      setup do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      should "not create a user" do
        assert_no_difference 'User.count' do
          post :create, :user => @attr
        end
      end
      
      should "have the right title" do
        post :create, :user => @attr
        assert_select "title", :content => "Sign Up"
      end
          
      should "render  the 'new' page" do
        post :create, :user => @attr
        assert_template 'new'
      end
    end

    context "success" do
    
      setup do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      should "create a user" do
        assert_difference 'User.count', 1 do
          post :create, :user => @attr
        end
      end
            
      should "redirect to the user show page" do
        post :create, :user => @attr
        assert_redirected_to user_path(assigns(:user))
      end

      should "have a welcome message" do
        post :create, :user => @attr
        assert_match flash[:success], /welcome to the sample app/i
      end
    end

  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
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

end

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  context "GET 'new'" do

    setup do
      get :new      
    end

    should "be successful" do
      assert_response :success
    end

    should "have the right title" do
      assert_select "title", :text=>/.*Sign in$/
    end

  end

  context "POST 'create'" do

    context "invalid signin" do

      setup do
        @attr = { :email => "email@example.com", :password => "invalid" }
        post :create, :session => @attr
      end

      should "re-render the new page" do
        assert_template 'new'
      end

      should "have the right title" do
        assert_select "title", /Sign in/
      end
      
      should "have a flash.now error message" do
        assert flash.now[:error] =~ /invalid/i
      end

      should "not be signed in" do
        assert !@controller.signed_in?
      end

    end

    context "with a brand new user" do
      
      setup do
        @attr = {email: "test@email.tst",  password: "testpwd"}
        @user=User.create! @attr.merge({name: "test_user", password_confirmation: "testpwd"})
      end

      context "before activating" do

        setup do
          post :create, :session => @attr
        end

        should "not have current_user" do
          assert_nil @controller.current_user
        end

        should "no have any signed in user" do
          assert ! @controller.signed_in?
        end

        should "redirect to the root page" do
          assert_redirected_to new_activation_token_path
        end

      end

      context "after activation" do

        setup do
          @user.activate
          post :create, :session => @attr
        end

        should "have correct current_user" do
          assert_equal @user, @controller.current_user
        end

        should "sign in the user" do
          assert @controller.signed_in?
        end

        should "redirect to the user show page" do
          assert_redirected_to user_path(@user)
        end

      end


    end

  end
  
  context "DELETE 'destroy'" do

    setup do
      @attr = {email: "test@email.tst",  password: "testpwd"}
      @user=User.create! @attr.merge({name: "test_user", password_confirmation: "testpwd"})
      test_sign_in(@user)   # simulem que l'usuari ja es al sistema
      delete :destroy
    end

    should "sign a user out" do
      assert !@controller.signed_in?
    end

    should "redirect to root" do
      assert_redirected_to root_path
    end

  end

end

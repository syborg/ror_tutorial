require 'test_helper'

class MicropostsControllerTest < ActionController::TestCase


  context "not signed in" do

    setup do
      @mp = microposts(:one)
    end

    should "deny access to 'create'" do
      post :create
      assert_redirected_to signin_path
    end

    should "deny access to 'destroy'" do
      delete :destroy, :id => @mp
      assert_redirected_to signin_path
    end
  end

  context "POST 'create'" do

    context "signed in" do

      setup do
        @user = users(:one)
        test_sign_in(@user)
      end

      context "with bad content" do

        setup do
          @attr = { :content => "" }
        end

        should "not create a micropost" do
          assert_no_difference 'Micropost.count' do
            post :create, :micropost => @attr
          end
        end

        should "render the home page" do
          post :create, :micropost => @attr
          assert_template 'pages/home'
        end
      end

      context "with correct content" do

        setup do
          @attr = { :content => "Lorem ipsum" }
        end

        should "create a micropost" do
          assert_difference 'Micropost.count', 1 do
            post :create, :micropost => @attr
          end
        end

        should "redirect to the home page" do
          post :create, :micropost => @attr
          assert_redirected_to root_path
        end

        should "have a flash message" do
          post :create, :micropost => @attr
          assert_match  /micropost .* created/i, flash[:success]
        end
      end

    end

  end

  context "DELETE 'destroy'" do

    context "for not an owner" do

      setup do
        @user = users(:one)
        @micropost = microposts(:one)
        @signed_user = users(:wrong_user)
        test_sign_in(@signed_user)
      end

      should "not destroy the micropost" do
        assert_difference 'Micropost.count', 0 do
          delete :destroy, :id => @micropost
        end
      end

      should "deny access" do
        delete :destroy, :id => @micropost
        assert_redirected_to root_path
      end
    end

    context "for an owner" do

      setup do
        @user = users(:one)
        test_sign_in(@user)
        @micropost = microposts(:one)
      end

      should "destroy the micropost" do
        assert_difference 'Micropost.count', -1 do
          delete :destroy, :id => @micropost
        end
      end
    end
  end

end

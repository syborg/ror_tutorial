require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase

  context "access control" do
    should "require signin for create" do
      post :create
      assert_redirected_to signin_path
    end

    should "require signin for destroy" do
      delete :destroy, :id => 1
      assert_redirected_to signin_path
    end
  end

  context "POST 'create'" do
    setup do
      @user = test_sign_in(users(:one))
      @followed = users(:two)
    end

    should "create a relationship" do
      assert_difference 'Relationship.count', 1 do
        post :create, :relationship => { :followed_id => @followed }
        assert_response :redirect
      end
    end

    should "create a relationship using Ajax" do
      assert_difference 'Relationship.count', 1 do
        xhr :post, :create, :relationship => { :followed_id => @followed }
        assert_response :success
      end
    end
  end

  context "DELETE 'destroy'" do
    setup do
      @user = test_sign_in(users(:one))
      @followed = users(:two)
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end

    should "destroy a relationship" do
      assert_difference 'Relationship.count', -1 do
        delete :destroy, :id => @relationship
        assert_response :redirect
      end
    end

    should "destroy a relationship using Ajax" do
      assert_difference 'Relationship.count', -1 do
        xhr :delete, :destroy, :id => @relationship
        assert_response :success
      end
    end
  end
end

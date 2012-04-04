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

  context "GET 'home'" do

    context "when not signed in" do

      setup do
        get :home
      end

      should "be successful" do
        assert_response :success
      end

      should "have the right title" do
        assert_select "title", :text=>/.*Home$/
      end
    end

    context "when signed in" do

      setup do
        @user = test_sign_in(users(:one))
        other_user = users(:two)
        other_user.follow!(@user)
        get :home
      end

      should "have the right follower/following counts" do
        assert_select "a[href=?]",following_user_path(@user), :text => "0 following"
        assert_select "a[href=?]",followers_user_path(@user), :text => "1 follower"
      end
    end
  end

end

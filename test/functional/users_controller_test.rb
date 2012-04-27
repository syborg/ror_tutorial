require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # new
  context "GET 'new'" do

    should "be successful" do
      get 'new'
      assert_response :success
    end
    
    should "have the right title" do
      get 'new'
      assert_select "title", :text=>/.*Sign Up$/
    end
    
    %w{name email password password_confirmation}.each do |fld|
      should "have a #{fld} field" do
        get :new
        assert_select "label", :for => "user_#{fld}"
      end
    end

  end

  # The show must go on
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

    should "show the user's microposts" do
      mp1 = microposts(:one)
      mp2 = microposts(:two)
      get :show, :id => @user
      assert_select("span.content", :text => mp1.content)
      assert_select("span.content", :text => mp2.content)
    end

    should "not enable micropost's delete links" do
      get :show, :id => @user
      assert_select "table.microposts td>a", :text => "delete", :count => 0
    end

    context "as signed in microposts owner" do

      setup do
        test_sign_in(@user)
        @user.toggle!(:admin)
      end

      should "have delete links for microposts" do
        get :show, :id => @user
        assert_select "table.microposts td>a", :text => "delete"
      end

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
        assert_select "title", :text => /Sign Up/
      end
          
      should "render the 'new' page" do
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

      should "sign in the user" do
         post :create, :user => @attr
         assert @controller.signed_in?
      end
    end

  end

  # destroy
  context "DELETE 'destroy'" do

    setup do
      @user=users(:two)
    end

    context "as a non-signed-in user" do
      should "deny access" do
        delete :destroy, :id=>@user
        assert_redirected_to signin_path
      end
    end

    context "as a signed" do

      setup do
        @admin_usr=users(:one)
        test_sign_in(@admin_usr)
      end
      
      context "non-admin user" do

        should "protect the page" do
          delete :destroy, :id=>@user.id
          assert_redirected_to root_path
        end

      end

      context "admin user" do

        setup do
          @admin_usr.toggle!(:admin)
        end

        should "destroy the user" do
          assert_difference 'User.count', -1 do
            delete :destroy, :id=>@user.id
          end
        end

        should "not destroy himself" do
          assert_no_difference 'User.count' do
            delete :destroy, :id=>@admin_usr.id
          end
        end

        should "redirect to the users page" do
          delete :destroy, :id=>@user.id
          assert_redirected_to users_path
        end
      end

    end

  end

  # edit
  context "GET 'edit'" do

    setup do
      @user = users(:one)
      test_sign_in @user
      get :edit, :id => @user
    end

    should "be successful" do
      assert_response :success
    end

    should "have the right title" do
      assert_select "title", :text=>/.*Edit User$/
    end

    should "have a Gravatar avatar image" do
      assert_select "img[src=?]", %r(http:\/\/gravatar\.com.+)
    end

    should "have a link to change the Gravatar" do
      gravatar_url = "http://gravatar.com/emails"
      assert_select "a[href=?]", gravatar_url, :text => "canvia avatar"
    end

  end

  # update
  context "PUT 'update'" do

    setup do
      @user = users(:one)
      test_sign_in(@user)
    end

    context "failure" do

      setup do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
        put :update, :id => @user, :user => @attr
      end

      should "render the 'edit' page" do
        assert_template 'edit'
      end

      should "have the right title" do
        assert_select "title", :text => /Edit user/
      end
    end

    context "success" do

      setup do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
        put :update, :id => @user, :user => @attr
      end

      should "change the user's attributes" do
        @user.reload
        assert_equal @user.name, @attr[:name]
        assert_equal @user.email, @attr[:email]
      end

      should "redirect to the user show page" do
        assert_redirected_to user_path(@user)
      end

      should "have a flash message" do
        assert_match /.*updated.*/, flash[:success]
      end
    end
  end

  # index
  context "GET 'index'" do

    context "for non-signed-in users" do
      should "deny access" do
        get :index
        assert_redirected_to signin_path
        assert_match /.*signegi-in.*/, flash[:notice]
      end
    end

    context "for signed-in users" do

      setup do
        @user = users(:one)
        second = users(:two)
        third = users(:three)
        @users = [@user, second, third]
        test_sign_in(@user)
        1.upto(10) do |n|
          @users << User.create( name: "User #{n}",
            email: "user#{n}@email.com",
            password: "password",
            password_confirmation: "password" )
        end
      end

      should "be successful" do
        get :index
        assert_response :success
      end

      should "have the right title" do
        get :index
        assert_select "title", :text => /.*All users.*/
      end

      should "have an element for each user" do
        get :index
        @users[0..2].each do |user|
          assert_select("ul.users li a", :text => user.name)
        end
      end

      should "paginate users" do
        get :index
        assert_select("div.pagination")
        assert_select("span.disabled", :text => /.*Previous.*/)
        assert_select("a[href=?]", %r{.*\/users\?page=2}, :text => "2")
        assert_select("a[href=?]", %r{.*\/users\?page=2}, :text => /Next.*/)
      end

      context "not admin users" do

        should "not have delete links" do
          get :index
          assert_select "ul.users a[data-method=delete]", 0
        end

      end

      context "admin users" do

        setup do
          @user.toggle!(:admin)
        end

        should "have delete links" do
          get :index
          assert_select "ul.users a[data-method=delete]"
        end

      end

    end
  end

  context "authentication of edit/update pages" do

    setup do
      @user = users(:one)
    end

    context "for non-signed-in users" do

      should "deny access to 'edit'" do
        get :edit, :id => @user
        assert_redirected_to signin_path
      end

      should "deny access to 'update'" do
        put :update, :id => @user, :user => {}
        assert_redirected_to signin_path
      end
    end

    context "for wrong signed-in users" do

      setup do
        wrong_user = users(:two)
        test_sign_in(wrong_user)
      end

      should "require matching users for 'edit'" do
        get :edit, :id => @user
        assert_redirected_to root_path
      end

      should "require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        assert_redirected_to root_path
      end

    end

  end

  context "follow pages" do

    context "when not signed in" do

      should "protect 'following'" do
        get :following, :id => 1
        assert_redirected_to signin_path
      end

      should "protect 'followers'" do
        get :followers, :id => 1
        assert_redirected_to signin_path
      end
    end

    context "when signed in" do

      setup do
        @user = test_sign_in(users(:one))
        @other_user = users(:two)
        @user.follow!(@other_user)
      end

      should "show user following" do
        get :following, :id => @user.id
        assert_select "a[href=?]", user_path(@other_user), :text => @other_user.name
      end

      should "show user followers" do
        get :followers, :id => @other_user.id
        assert_select "a[href=?]", user_path(@user), :text => @user.name
      end
    end
  end

  context "reply users" do

    context "when not signed in" do

      setup do
        @other_user = users(:two)
      end

      should "protect 'reply'" do
        get :reply, :id => @other_user
        assert_redirected_to signin_path
      end

    end

    context "when signed in" do

      setup do
        @user = test_sign_in(users(:one))
        @replied_user = users(:two)
        get :reply, :id => @replied_user
      end

      should "render the 'reply' template" do
        assert_template 'reply'
      end

      should "show replied user name" do
        assert_select "h1.micropost", :text => /.*#{@replied_user.name}/
      end

      should "include a hidden replied user within the form" do
        assert_select "form", 1 do
          assert_select "input[type=?][value=?]", "hidden", @replied_user.id
        end
      end

    end

  end

  context "messages with users" do

    context "when not signed in" do

      setup do
        @other_user = users(:two)
      end

      should "protect 'reply'" do
        get :message, :id => @other_user
        assert_redirected_to signin_path
      end

    end

    context "when signed in" do

      setup do
        @sender = test_sign_in(users(:one))
        @receiver = users(:two)
        get :message, :id => @receiver
      end

      should "render the 'message' template" do
        assert_template 'message'
      end

      should "show receiver name" do
        assert_select "h1.micropost", :text => /.*#{@receiver.name}/
      end

      should "include a hidden receiver within the form" do
        assert_select "form", 1 do
          assert_select "input[type=?][value=?]", "hidden", @receiver.id
        end
      end

      should "include a hidden private within the form" do
        assert_select "form", 1 do
          assert_select "input[type=?][value=?]", "hidden", true
        end
      end

    end

  end

  # password reminders
  context "PUT 'password'" do

    setup do
      @attr = {:name=>"Julius Erwing",
               :email => "je@email.tst",
               :password => "password",
               :password_confirmation => "password"}
      @user = User.create! @attr
    end

    context "when password reminder exists" do

      setup do
        @pwd = @user.generate_password_reminder
      end

      should "remove password reminder when user logs in" do
        assert_difference "PasswordReminder.count", -1 do
          test_sign_in @user
        end
      end

      should "redirect to root when password correctly set" do
        put :password, :token=>@pwd.token, :user => @attr
        assert_redirected_to root_path
      end

      should "output a flash success message" do
        put :password, :token=>@pwd.token, :user => @attr
        assert_equal 'Password updated', flash[:success]
      end

      should "retry password update when password wrongly set" do
        put :password, :token=>@pwd.token, :user => @attr.merge(:password=>"wrong_password")
        assert_template "password_reminders/edit"
      end

    end

    context "when password reminder doesn't exist" do

      setup do
        put :password, :token=>"obsoletetoken", :user => @attr
      end

      should "not be able to update password" do
        assert_redirected_to root_path
      end

      should "output a flash error message" do
        assert_equal 'Invalid Password Reminder', flash[:error]
      end

    end

  end

end

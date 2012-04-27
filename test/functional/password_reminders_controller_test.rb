require 'test_helper'

class PasswordRemindersControllerTest < ActionController::TestCase

  context "GET 'new'" do

    setup do
      get :new      
    end

    should "be successful" do
      assert_response :success
    end

    should "have the right title" do
      assert_select "title", :text=>/.*Recreate Password$/
    end

  end

  context "POST 'create'" do

    context "invalid email" do

      setup do
        @params = { :email => "email@example.com" }
        post :create, :password_reminder=>@params
      end

      should "re-render the new page" do
        assert_template 'new'
      end

      should "have the right title" do
        assert_select "title", /Recreate Password/
      end

      should "have a flash.now error message" do
        assert flash.now[:error] =~ /User/i
      end

    end

    context "with valid email" do
      
      setup do
        @params = {email: "test@email.tst"}
        @user=User.create! @params.merge({name: "test_user", password: "testpwd", password_confirmation: "testpwd"})
      end

      should "generate a password reminder" do
        assert_difference "PasswordReminder.count", 1 do
          post :create, :password_reminder => @params
          assert_response :redirect
        end
      end

      should "send reminder by email to user" do
        assert_difference "ActionMailer::Base.deliveries.count", 1 do
          post :create, :password_reminder => @params
          assert_response :redirect
        end
      end

      should "redirect to the root path" do
        post :create, :password_reminder => @params
        assert_redirected_to root_path
      end

    end

  end
  
  context "GET 'edit'" do

    setup do
      @params = {email: "test@email.tst"}
      @user=User.create! @params.merge({name: "test_user",
                                        password: "testpwd",
                                        password_confirmation: "testpwd",
                                        admin: false,
                                        notify_followers: true})
      @pr=@user.generate_password_reminder
      get :edit, :token=>@pr.token
    end

    should "show edit page (password recreation)" do
      assert_template 'edit'
    end

    should "have all user's fields hidden but password and password_confirmation" do
      assert_select "form" do
        %w[name email].each do |attr|
          assert_select "input[type=hidden][id=user_#{attr}][value=?]", @user.send(attr)
        end
      end
    end

    should "have password and password_confirmation visible" do
      assert_select "form" do
        %w[password password_confirmation].each do |attr|
          assert_select "input[id=user_#{attr}]"
        end
      end
    end

  end

end

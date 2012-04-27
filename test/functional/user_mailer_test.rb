require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  %w[new_follower_notification old_follower_notification].each do |ntf|

    context ntf do

      setup do
        @user = users(:one)
        @follower = users(:two)
        @email = eval "UserMailer.#{ntf}(@user, @follower).deliver"
      end

      should "send an email when prompted to do it" do
        assert !ActionMailer::Base.deliveries.empty?  # en Test els mails nomes van a una cua
      end

      should "send an email to a user from support@rettiwet.com" do
        assert_equal @email.to, [@user.email]
        assert_equal @email.from, ["support@rettiwet.com"]
      end

      should "contain followed and follower names" do
        assert_match /.*#{@user.name}.*/, @email.body
        assert_match /.*#{@follower.name}.*/, @email.body
      end

    end

  end

  context "password_reminder" do

      include ActionView::Helpers::UrlHelper

    setup do
      PasswordReminder.delete_all
      @user=users(:one)
      @pr=@user.generate_password_reminder
      @email=UserMailer.password_reminder(@user).deliver
    end

    should "send an email when prompted to do it" do
      assert !ActionMailer::Base.deliveries.empty?  # en Test els mails nomes van a una cua
    end

    should "send an email to a user from support@rettiwet.com" do
      assert_equal @email.to, [@user.email]
      assert_equal @email.from, ["support@rettiwet.com"]
    end

    should "contain link to password_reminder" do
      assert_match /.*reminder\/#{@pr.token}.*/, @email.body
    end

  end

end

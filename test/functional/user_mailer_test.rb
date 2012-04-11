require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  context "new_follower_notification" do

    setup do
      @user = users(:one)
      @follower = users(:two)
      @email = UserMailer.new_follower_notification(@user, @follower).deliver
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

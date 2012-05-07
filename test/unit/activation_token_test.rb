# == Schema Information
#
# Table name: password_reminders
#
#  id      :integer         not null, primary key
#  user_id :integer
#  token   :string(255)
#

require 'test_helper'

class ActivationTokenTest < ActiveSupport::TestCase

  context "an activation token" do

    setup do
      @user = users(:one)
      @at = @user.generate_activation_token
    end

    should "have a 'token' method" do
      assert @at.respond_to? :token
    end

    should "have a user method" do
      assert @at.respond_to? :user
    end

    should "correspond to the user that created it" do
      assert_equal @at.user, @user
    end

  end

end

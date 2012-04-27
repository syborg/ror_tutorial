# == Schema Information
#
# Table name: password_reminders
#
#  id      :integer         not null, primary key
#  user_id :integer
#  token   :string(255)
#

require 'test_helper'

class PasswordReminderTest < ActiveSupport::TestCase

  context "a password reminder" do

    setup do
      @user = users(:one)
      @pr = @user.generate_password_reminder
    end

    should "have a user method" do
      assert @pr.respond_to? :user
    end

    should "correspond to the user that created it" do
      assert_equal @pr.user, @user
    end

  end


end

# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  setup do
    @user = users(:one)
    @attr = { :content => "value for content" }
  end

  should "create a new instance given valid attributes" do
    @user.microposts.create(@attr)
  end

  context "user associations" do

    setup do
      @micropost = @user.microposts.build(@attr)
    end

    should "have a user attribute" do
      assert_respond_to @micropost, :user
    end

    should "have the right associated user" do
      assert_equal @micropost.user_id, @user.id
      assert_equal @micropost.user, @user
    end

  end

  context "validations" do
   
    should "require a user id" do
      assert ! Micropost.new(@attr).valid?
    end

    should "require nonblank content" do
      # MME es com Micropost.new pero ja li assigna un user_id
      assert ! @user.microposts.build(:content => "  ").valid?
    end

    should "reject long content" do
      assert ! @user.microposts.build(:content => "a" * 141).valid?
    end

  end

end

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

  context "from_users_followed_by" do

    setup do
      @other_user = users(:two)
      @third_user = users(:three)

      @user_post  = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")

      @user.follow!(@other_user)
    end

    should "have a from_users_followed_by class method" do
      assert Micropost.respond_to? :from_users_followed_by
    end

    should "respond to paginate" do
      mps = Micropost.from_users_followed_by(@user)
      assert mps.respond_to? :paginate
    end

    should "include the followed user's microposts" do
      assert_include Micropost.from_users_followed_by(@user), @other_post
    end

    should "not change the followed user's micropost owner" do
      assert_equal  @other_post.user_id, @other_user.id
    end

    should "include the user's own microposts" do
      assert_include Micropost.from_users_followed_by(@user), @user_post
    end


    should "not include an unfollowed user's microposts" do
      assert_not_include Micropost.from_users_followed_by(@user), @third_post
    end
  end
  
end

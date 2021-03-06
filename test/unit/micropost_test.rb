# == Schema Information
#
# Table name: microposts
#
#  id          :integer         not null, primary key
#  content     :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  in_reply_to :integer
#  private     :boolean
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
      assert_respond_to Micropost, :from_users_followed_by
    end

    should "respond to paginate" do
      mps = Micropost.from_users_followed_by(@user)
      assert_respond_to mps, :paginate
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

  # MME a message is a reply with private set to true
  context "replies and messages" do

    setup do
      @other_user = users(:two)
    end

    context "a reply" do

      setup do
        @mp = @other_user.replies_to @user, "Hi I'm two"
      end

      should "be a reply" do
        assert @mp.is_reply?
      end

      should "not be a message" do
        assert ! @mp.is_message?
      end

    end

    context "a estandard micropost" do

      setup do
        @mp = @other_user.microposts.build :content=>"Hi I'm two"
      end

      should "not be a reply" do
        assert ! @mp.is_reply?
      end

      should "not be a message" do
        assert ! @mp.is_message?
      end

    end

    context "a message" do

      setup do
        @mp = @other_user.sends_to @user, "Hi I'm two"
      end

      should "not be a reply" do
        assert ! @mp.is_reply?
      end

      should "be a message" do
        assert @mp.is_message?
      end

      should "add a message in microposts" do
        assert_include Micropost.messages, @mp
      end

    end

    context "a micropost with parseable content" do

      setup do
        @other_user=User.create :name => "Rodolfo Pinchon",
                                :email => "user@example.com",
                                :password => "foobar",
                                :password_confirmation => "foobar"
      end

      context "if intended recipient user exists" do

        should "become a reply if begins with '@'+pseudo_login_name" do
          mp = @user.microposts.create :content=>"@rodolfo_pinchon Hi, I'm the one"
          mp.parse_and_patch
          assert mp.is_reply?
        end

        should "become a message if begins with '*'+pseudo_login_name" do
          mp = @user.microposts.create :content=>"*rodolfo_pinchon Hi, I'm the one"
          mp.parse_and_patch
          assert mp.is_message?
        end

        should "clear [*|@]+pseudo_login_name from content if correctly parsed" do
          mp = @user.microposts.create :content=>"@rodolfo_pinchon Hi, I'm the one"
          mp.parse_and_patch
          assert_equal mp.content, "Hi, I'm the one"
        end

        should "be untouched if it doesn't begin with '@'+pseudo_login_name or '*'+pseudo_login_name" do
          cntnt="jrodolfo_pinchon Hi, I'm the one"
          mp = @user.microposts.create :content=>cntnt
          mp.parse_and_patch
          assert_equal mp.content, cntnt
        end

      end

    end

  end

end

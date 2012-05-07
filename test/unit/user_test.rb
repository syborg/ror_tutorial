# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  notify_followers   :boolean         default(TRUE)
#  state              :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

	setup do
	  @attr = {
	      :name => "Example User",
	      :email => "user@example.com",
	      :password => "foobar",
	      :password_confirmation => "foobar"
	    }
	end

	test "should create a new instance given attributes" do
		assert User.create @attr
	end

	test "should require a name" do
		user = User.new @attr.merge(:name=>"")
		assert ! user.save, "name buid"
	end

	test "should require a mail address" do
		user = User.new @attr.merge(:email=>"")
		assert ! user.save, "email buid"
	end

	test "should not have a long name" do
		user = User.new @attr.merge(:name => "a"*51)
		assert ! user.save, "name massa llarg"
	end

	test "should accept valid email addresses" do
		addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
		addresses.each do |address|
		  user = User.new @attr.merge(:email => address)
		  assert user.save, "#{address} not accepted"
		end
	end

	test "should reject invalid email addresses" do
		addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
		addresses.each do |address|
		  user = User.new @attr.merge(:email => address)
		  assert ! user.save, "#{address} accepted"
		end
	end

	test "should reject duplicate email addresses" do
		attr1 = @attr.merge(:name => "pep")
		attr2 = @attr.merge(:name => "pipo")
		User.create! attr1
		user = User.new attr2
		assert ! user.save, "email duplicated"
	end

	test "should reject email addresses identical up to case" do
		attr = @attr.merge(:email => "pep@gmail.com")
		addresses = %w{PEP@GMAIL.COM Pep@Gmail.Com pEp@gMaIl.CoM}
		User.create! attr
		addresses.each do |address|
		  user = User.new attr.merge(:email => address)
		  assert ! user.save, "#{address} duplicated"
		end
	end

	test "should require a password" do
		user=User.new @attr.merge(:password => "", :password_confirmation => "")
		assert ! user.save, "password cannot be empty"
	end

	test "should require a matching password confirmation" do
		user=User.new @attr.merge(:password_confirmation => "invalid")
		assert ! user.save, "password confirmation should be valid"
	end

	test "should reject short passwords" do
		short = "a" * 5
		user=User.new @attr.merge(:password => short, :password_confirmation => short)
		assert ! user.save, "password cannot be short"
	end

	test "should reject long passwords" do
		long = "a" * 41
		user=User.new @attr.merge(:password => long, :password_confirmation => long)
		assert ! user.save, "password cannot be long"
	end

	context "a user with password" do
		
		setup do
  			@user = User.create! @attr
		end

		should "have an encrypted password attribute" do
	      assert_respond_to @user, :encrypted_password
	    end

	    should "set an encrypted password" do
	      assert_present @user.encrypted_password, "encrypted password must not be blank"
	    end

		should "have non recognizable password" do
			assert_not_equal @user.encrypted_password, @attr[:password]
		end

	end

	context "has_password? method" do

		setup do
  			@user = User.create! @attr
		end

		should "be true if the passwords match" do
			assert @user.has_password?(@attr[:password])
		end

		should "be false if the passwords don't match" do
			assert ! @user.has_password?("unaltre")
		end
	end

	context "authenticate method" do
		
		setup do
			@user = User.create! @attr
		end

		should "return nil on email/password mismatch" do
			assert_nil User.authenticate(@user.email, "wrong_password")
		end
		
		should "return nil for an email address with no user" do
			assert_nil User.authenticate("nouser@email.com", "password")
		end

		should "return the user on email/password match" do
			assert_equal @user, User.authenticate(@user.email, @user.password)
		end
			
	end

  context "admin attribute" do

    setup do
      @user = User.create!(@attr)
    end

    should "respond to admin" do
      assert @user.respond_to?("admin?")
    end

    should "not be an admin by default" do
      assert !@user.admin?
    end

    should "be convertible to an admin" do
      @user.toggle!(:admin)
      assert @user.admin?
    end
  end

  context "pseudo_login_name" do

    should "return downcased name with underscores and id" do
      user = User.create @attr
      assert_equal user.pseudo_login_name, "example_user_#{user.id.to_s}"
    end

    should "return the correct User when last part is the id" do
      user = User.create @attr
      user_found = User.find_by_pseudo_login_name "blablabla_#{user.id.to_s}"
      assert_equal user, user_found
    end

    should "return the correct User when first part is the downcased name with underscores" do
      user = User.create @attr
      user_found = User.find_by_pseudo_login_name "example_user"
      assert_equal user, user_found
    end

  end

  context "micropost associations" do

    setup do
      @user = users(:one)
      @mp1 = microposts(:one)
      @mp2 = microposts(:two)
      @mp3 = microposts(:three)
    end

    should "have a microposts attribute" do
      assert_respond_to @user, :microposts
    end

    should "have the right microposts in the right order" do
      assert_equal @user.microposts, [@mp2, @mp3, @mp1]
    end

    should "destroy associated microposts" do
      cnt = - @user.microposts.count
      assert_difference 'Micropost.count', cnt do
        @user.destroy
      end
    end

    context "status feed" do

      should "have a feed" do
        assert_respond_to @user, :feed
      end

      should "include the user's microposts" do
        assert_include @user.feed, @mp1
        assert_include @user.feed, @mp2
        assert_include @user.feed, @mp3
      end

      should "not include a different user's microposts" do
        # :four no pertany al user :one, si no al :two (veure les fixtures)
        mp4 = microposts(:four)
        assert_not_include @user.feed, mp4
      end

      should "include the microposts of followed users" do
        followed = users(:two)
        # :four no pertany al user :one, si no al :two (veure les fixtures)
        mp4=microposts(:four)
        @user.follow!(followed)
        assert_include @user.feed, mp4
      end

    end

    context "user with replies" do

      setup do
        @user_two=users(:two)
        @user_three=users(:three)
        @reply_to_user = @user_two.replies_to @user, "Hi I'm two"
        @reply_to_two = @user_three.replies_to @user_two, "Hi I'm three"
      end

      should "have a replies attribute" do
        assert_respond_to @user, :replies
      end

      should "have replies" do
        assert_include @user.replies, @reply_to_user
        assert_include @user_two.replies, @reply_to_two
      end

      should "be replied by replies" do
        assert_equal @reply_to_user.replied_user, @user
        assert_equal @reply_to_two.replied_user, @user_two
      end

      should "delete all its own microposts and replies upon self deletion" do
        cnt = @user_two.replies.count + @user_two.microposts.count
        assert_difference "Micropost.count", -cnt do
          @user_two.destroy
        end
      end

    end

    context "user with messages" do

      should "have a messages_to attribute" do
        assert_respond_to @user, :messages_to
      end

      should "have a messages_from attribute" do
        assert_respond_to @user, :messages_from
      end

      should "have a messages_to_or_from attribute" do
        assert_respond_to @user, :messages_to_or_from
      end

      context "having sent a message" do

        setup do
          @other_user=users(:two)
          @mss1 = @user.sends_to @other_user, "Hi I'm the user"
          @mss2 = @other_user.sends_to @user, "Hi I'm the other"
        end

        should "have messages sent to a recipient in self.messages_to(recipient)" do
          assert_include @user.messages_to(@other_user), @mss1
          assert_include @other_user.messages_to(@user), @mss2
        end

        should "have messages received from a sender in self.messages_from(sender)" do
          assert_include @user.messages_from(@other_user), @mss2
          assert_include @other_user.messages_from(@user), @mss1
        end

        should "not mix messages from and to" do
          assert_not_include @user.messages_to(@other_user), @mss2
          assert_not_include @other_user.messages_to(@user), @mss1
          assert_not_include @user.messages_from(@other_user), @mss1
          assert_not_include @other_user.messages_from(@user), @mss2
        end

        should "not mix third user's messages" do
          third_user=users(:three)
          mss3 = third_user.sends_to @user, "Hi I'm 3"
          assert_not_include @user.messages_from(@other_user), mss3
          assert_not_include @user.messages_to_or_from(@other_user), mss3
        end
        
        should "mix all sent and received messages with another user in messages_to_or_from" do
          assert_include @user.messages_to_or_from(@other_user), @mss2
          assert_include @other_user.messages_to_or_from(@user), @mss1
          assert_include @user.messages_to_or_from(@other_user), @mss1
          assert_include @other_user.messages_to_or_from(@user), @mss2
        end

      end

    end

  end

  context "relationships" do

    setup do
      @user = User.create!(@attr)
      @followed = users(:one)
    end

    should "enable a relationships method" do
      assert_respond_to @user, :relationships
    end

    should "enable a following method" do
      assert_respond_to @user, :following
    end

    should "enable a following? method" do
      assert_respond_to @user, :following?
    end

    should "enable a follow! method" do
      assert_respond_to @user, :follow!
    end

    should "enable to follow another user" do
      @user.follow!(@followed)
      assert @user.following? @followed
    end

    should "include the followed user in the following array" do
      @user.follow!(@followed)
      assert @user.following.include? @followed
    end

    should "enable an unfollow! method" do
      assert_respond_to @followed, :unfollow!
    end

    should "enable to unfollow a followed user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      assert !@user.following?(@followed)
    end

    should "enable to assure to unfollow an already unfollowed user" do
      @user.unfollow!(@followed)
      assert !@user.following?(@followed)
    end

    should "have a reverse_relationships method" do
      assert_respond_to @user, :reverse_relationships
    end

    should "have a followers method" do
      assert_respond_to @user, :followers
    end

    should "include the follower in the followers array" do
      @user.follow!(@followed)
      assert_include @followed.followers, @user
    end

  end

  context "users with password reminder" do

    setup do
      @user=users(:one)
      @user_two=users(:two)
    end

    should "have a password_reminder method" do
      assert @user.respond_to? :password_reminder
    end

    should "have a generate_password_reminder method" do
      assert @user.respond_to? :generate_password_reminder
    end

    should "have a remove_password_reminder method" do
      assert @user.respond_to? :remove_password_reminder
    end

    should "match with assigned token" do
      @user.create_password_reminder :token=>"token"
      assert_equal @user.password_reminder.token, "token"
    end

    should "not share password reminders" do
      @user.create_password_reminder :token=>"token"
      assert_raise ActiveRecord::StatementInvalid do
        @user_two.create_password_reminder(:token=>"token")
      end
    end

    should "have no more than one reminder" do
      @user.generate_password_reminder
      assert_no_difference "PasswordReminder.count" do
        @user.generate_password_reminder
      end
    end

    should "remove his password reminder if it already exists" do
      @user.generate_password_reminder
      assert_difference "PasswordReminder.count", -1  do
        @user.remove_password_reminder
      end
    end

    should "not remove any password reminder if it doesn't exist" do
      assert_no_difference "PasswordReminder.count" do
        @user.remove_password_reminder
      end
    end

  end

  context "state_machine to enable multiple step signup" do

    setup do
      attr = {
	      :name => "Example User",
	      :email => "user@example.com",
	      :password => "foobar",
	      :password_confirmation => "foobar"
	    }
      @user=User.create attr
    end

    should "have a activation_token method" do
      assert @user.respond_to? :activation_token
    end

    should "have a generate_activation_token method" do
      assert @user.respond_to? :generate_activation_token
    end

    should "have a remove_activation_token method" do
      assert @user.respond_to? :remove_activation_token
    end

    should "be initialized in 'inactive' state" do
      assert_equal @user.state, 'inactive'
    end

    should "be able to change to 'active' state" do
      @user.activate
      assert_equal @user.state, 'active'
    end

  end

end

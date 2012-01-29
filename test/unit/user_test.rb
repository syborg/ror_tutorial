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

end

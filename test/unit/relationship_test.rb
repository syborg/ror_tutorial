# == Schema Information
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  setup do

    @followed=users(:one)
    @follower=users(:two)

    @relationship=@follower.relationships.build(:followed_id => @followed.id)

  end

  should "create a new instance given valid attributes" do
    assert @relationship.save!
  end

  context "follow methods" do

    setup do
      @relationship.save  # no provoca excepcio
    end

    should "have a follower attribute" do
      assert_respond_to @relationship,:follower
    end

    should "have the right follower" do
      assert_equal @relationship.follower, @follower
    end

    should "have a followed attribute" do
      assert_respond_to @relationship, :followed
    end

    should "have the right followed user" do
      assert_equal @relationship.followed, @followed
    end

  end

  context "validations" do

    should "require a follower_id" do
      @relationship.follower_id=nil
      assert !@relationship.valid?
    end

    should "require a followed_id" do
      @relationship.followed_id=nil
      assert !@relationship.valid?
    end
  end

end

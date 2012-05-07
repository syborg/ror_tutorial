# == Schema Information
#
# Table name: activation_tokens
#
#  id      :integer         not null, primary key
#  user_id :integer
#  token   :string(255)
#

class ActivationToken < ActiveRecord::Base

  attr_accessible :token

  belongs_to :user

end

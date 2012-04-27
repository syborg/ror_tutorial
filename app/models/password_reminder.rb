# == Schema Information
#
# Table name: password_reminders
#
#  id      :integer         not null, primary key
#  user_id :integer
#  token   :string(255)
#

class PasswordReminder < ActiveRecord::Base

  attr_accessible :token

  belongs_to :user

end

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

class Micropost < ActiveRecord::Base

  attr_accessible :content
  
  validates :content, length: {maximum: 140},  # MME maxim 140 caracters
                      presence: true
                      #format: {with: /\S+/}   # MME al menys 1 caracter "no espai"
  validates :user_id, presence: true

  belongs_to :user

  # MME si no s'especifica altra per a totes les consultes aplica el següent
  default_scope :order => 'microposts.created_at DESC'

end

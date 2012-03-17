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

class Relationship < ActiveRecord::Base
  attr_accessible :followed_id    # unics atributs accesible via create o build o similars

  belongs_to :follower, :class_name => "User" # MME :follower es com es referencia el seguidor (clase User))
  belongs_to :followed, :class_name => "User" # MME :followed es com es referencia el seguit (tb clase User)

  # MME cada registre de relacio no te sentit si no vincula un seguit i un seguidor
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
end

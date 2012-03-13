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

  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  # Returns all own microposts and from following
  #def self.from_users_followed_by(user)
  #  #user.microposts + following_microposts(user)
  #  # 1 -> Problema. Torna un Array que no respon a :paginate
  #  #users_id = user.following.map(&:id) << user.id
  #  #Micropost.find_all_by_user_id(users_id)
  #  # 2 -> Problema. No torna els microposts del propi user (si es defineix aquesta associacio a User))
  #  #user.following_microposts
  #  # 3 -> OK!
  #  #users_id = user.following_ids << user.id  # a Rails user.following.map(&:id) == user.following_ids
  #  #Micropost.where(:user_id => users_id)
  #  # 4 -> Encara mes elegant!. Pero te un parell de problemes encara. Tota la informació s'agafa de cop, users i
  #  # microposts, i des del controlador es pagina. Si un usuari segueix a 5000 altres usuaris, tots els seus microposts
  #  # s'agafaran' un i altre cop que s'invoqui aquest metode.
  #  where(:user_id => user.following.push(user)) # affegim el propi usuari a l'array following, i where ja sap que ha
  #                                               # d'agafar els .id de cadascun dels elements
  #  # La manera mes optima d'implementar-ho es mitjançant scope i SQL SubSelects, de manera que nomes s'agafin els
  #  registres necessaris (veure cap 12.3.3). Es molt mes escalable.
  #end

  private

    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      following_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)
      where("user_id IN (#{following_ids}) OR user_id = :user_id",
            { :user_id => user }) # les aparicions de :user_id a la cadena son substituides pel user.id
    end

end

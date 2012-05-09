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

class Micropost < ActiveRecord::Base

  attr_accessible :content, :in_reply_to, :private
  
  validates :content, length: {maximum: 140},  # MME maxim 140 caracters
                      presence: true
                      #format: {with: /\S+/}   # MME al menys 1 caracter "no espai" (no cal si 'presence: true' ja hi es)
  validates :user_id, presence: true

  belongs_to :user

  # MME Afegim respostes als microposts
  belongs_to :replied_user, :class_name => 'User',
                            :inverse_of => :replies,
                            :foreign_key => "in_reply_to"

  # MME si no s'especifica altra per a totes les consultes aplica el següent
  default_scope :order => 'microposts.created_at DESC'

  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  scope :from_users_followed_by_or_in_reply_to, lambda { |user| followed_by_or_in_reply_to(user) }

  scope :messages, where(:private => true)

  scope :not_messages, where("(private = ?) OR (private IS NULL)", false)

  scope :to_or_from, lambda {|user| where("user_id=:id OR in_reply_to=:id", {:id=>user.id})}

  scope :between, lambda { |usr1, usr2|
    where("(user_id=:usr1 AND in_reply_to=:usr2) OR (user_id=:usr2 AND in_reply_to=:usr1)",
          {:usr1=>usr1.id, :usr2=>usr2.id})
  }


  # Returns all own microposts and from following
  #def self.from_users_followed_by(user)
  #  #user.microposts + user.following_microposts(user)
  #  # 1 -> Problema. Torna un Array que no respon a :paginate
  #  #users_id = user.following.map(&:id) << user.id
  #  #Micropost.find_all_by_user_id(users_id)
  #  # 2 -> Problema. No torna els microposts del propi user (si es defineix aquesta associacio a User))
  #  #user.following_microposts
  #  # 3 -> OK!, pero agafa tots els aquests microposts de cop
  #  #users_id = user.following_ids << user.id  # a Rails user.following.map(&:id) == user.following_ids
  #  #Micropost.where(:user_id => users_id)
  #  # 4 -> Igual que l'anterior per encara mes elegant!. Pero te un parell de problemes encara. Tota la informació
  #  # s'agafa de cop, users i microposts, i des del controlador es pagina. Si un usuari segueix a 5000 altres usuaris,
  #  # tots els seus microposts s'agafaran' un i altre cop que s'invoqui aquest metode.
  #  where(:user_id => user.following.push(user)) # affegim el propi usuari a l'array following, i where ja sap que ha
  #                                               # d'agafar els .id de cadascun dels elements
  #  # La manera mes optima d'implementar-ho es mitjançant scope i SQL SubSelects, de manera que nomes s'agafin els
  #  registres necessaris (veure cap 12.3.3). Es molt mes escalable.
  #end

  # MME Returns true if self is a reply to a user
  def is_reply?
    in_reply_to && ! self.private
  end

  # MME Returns true if self is a message to a user
  def is_message?
    in_reply_to && self.private
  end

  # MME parses content and if it begins with @ or * and a pseudo_login_name 
  # the Micropost is patched to become a reply or a message respectively
  def parse_and_patch
    if mch=self.content.match(/^([\*@])(\S+)\s+/)
      pln=mch[2]
      if usr=User.find_by_pseudo_login_name(pln)
        self.in_reply_to = usr.id
        self.private = mch[1] == '*' ? true : false
        self.content = self.content.sub(mch[0], "")
        self.save
      end
    end
    self    
  end

  private

    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      following_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)
      where("user_id IN (#{following_ids}) OR user_id = :user_id",
            { :user_id => user }) # les aparicions de :user_id a la cadena son substituides pel user.id
    end



    # Retorna una condicio SQL que permet trobar la llista de microposts d'un usuari, els seus seguits i els replies
    # que reb'
    def self.followed_by_or_in_reply_to(user)
      following_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
      where("user_id IN (#{following_ids}) OR user_id = :user_id OR in_reply_to = :user_id",
             { :user_id => user }) # les aparicions de :user_id a la cadena son substituides pel user.id
    end

end

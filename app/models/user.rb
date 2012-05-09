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

# MME per a utilitzar les Hash functions
require 'digest'

class User < ActiveRecord::Base

  attr_accessor :password # MME nomes dona acces a la instance var @password que no es guarda a la BBDD

  # MME si es posa, atributs (columnes) als que es podrà accedir via ActiveRecord
  attr_accessible	:name, :email, :password, :password_confirmation, :admin, :notify_followers

  # MME validacions (s'executen just abans de guardar-se a la BBDD si s'invoca save. S'eviten si s'invoca save(false))
  validates :name, :presence => true,
                   :length=> {maximum: 50}

  validates :email, :presence => true,
                    :format => { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    :uniqueness => { :case_sensitive => false}

  validates :password, :presence => true,
                       :confirmation => true,	# crea un atribut password_confirmation i a la vegada confirma que sigui igual que password
                       :length => { :within => 6..40 }

  # validates :password_confirmation, :presence => true	# MME aixo exigigeix que al crear es passi un :password_confirmation, doncs amb nomes
                  #	  l'anterior validator sol, pot crearse un usuari si no es passa :password_confirmation


  before_save :encrypt_password


  ## MME state_machine per a fer la inscripcio en passos.
  # Atencio, les validacions del model es poden insertar dins la maquina d'estats, perque si son fora, cada cop que es
  # canvia d'estat state_machine utilitza #save i aleshores es comproven totes les validacions, per la qual cosa no
  # canvia d'estat si no se li passen els atributs d'acord a les validacions esperades. Per evitar-ho, es pot redefinir
  # amb :action=> la nova funcio que es crida cada cop que es canvia d'estat, de manera que no es cridin les validacions
  # i/o els callbacks que per defecte fa 
  state_machine :initial => :inactive, :action=>:save_state do
    event :activate do
      transition :inactive => :active
    end
  end

  # MME a l'esborrar un User s'esborren tb els seus Micropost
  has_many :microposts, :dependent => :destroy

  # MME Afegim respostes als usuaris
  has_many :replies, :class_name => 'Micropost',
                     :foreign_key => "in_reply_to",
                     :inverse_of => :replied_user,
                     :dependent => :destroy

  ## User com a seguidor (follower)
  # te molts :relationships apuntant-lo amb la clau follower_id. Si el User s'elimina tots aquests Relationship tambe seran eliminats.
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  # te molts seguits via :relationships als que s'apunta via :followed_id  (inferit gracies a :followed, que apunta a la vegada als User)
  has_many :following, :through => :relationships,
                       :source => :followed

  ## User com a seguit (followed)
  # te molts :reverse_relationships apuntant-lo amb la clau followed_id. Si el User s'elimina tots aquests Relationship tambe seran eliminats.
  has_many :reverse_relationships, :class_name => "Relationship",
                                   :foreign_key => "followed_id",
                                   :dependent => :destroy
  # te molts seguidors via :reverse_relationships als que s'apunta via :follower_id  (inferit gracies a :follower, que apunta a la vegada als User)
  has_many :followers, :through => :reverse_relationships

  # Torna els microposts dels usuaris seguits per un user, per exemple:
  #    usr=User.find(12)
  #    usr.following_microposts
  # (no el faig anar finalment: Micropost.from_users_followed_by(user) ho he implementat sense aquests metode perque
  # em falten els microposts del propi user) 
  has_many :following_microposts, :through => :following, 
                                  :source => :microposts

  # Si n'hi ha, te un password_reminder
  has_one :password_reminder

  # Si n'hi ha, te un activation_token
  has_one :activation_token

  # Torna l'User de l'email si el password es correcte
  def self.authenticate(email, submited_pwd)
    if usr = find_by_email(email)
      usr.has_password?(submited_pwd) ? usr : nil
    else
      nil
    end
  end

  # Torna l'User del id si el salt es correcte (s'utilitza per les sessions)
  def self.authenticate_with_salt(id, salt)
    user = find_by_id(id)
    (user && user.salt == salt) ? user : nil
  end

  # verifica si el password correspon a l'User
  def has_password?(submited_pwd)
    self.encrypted_password == encrypt(submited_pwd)
  end

  def feed
    #Micropost.from_users_followed_by self
    # Microposts from
    #   self
    #   self.following
    #   self.replies
    Micropost.not_messages.from_users_followed_by_or_in_reply_to self
  end

  # Is usr being followed by self?
  def following? usr
    following.include? usr
    # MME segons el tutorial seria
    #relationships.find_by_followed_id(followed)
  end

  def follow! usr
    relationships.create! :followed_id => usr.id
  end

  def unfollow! usr
    relationships.find_by_followed_id(usr.id).destroy if following?(usr)
  end

  def replies_to(usr, content)
    microposts.create :content=>content, :in_reply_to=>usr.id, :private=>false
  end

  def sends_to(usr, content)
    microposts.create :content=>content, :in_reply_to=>usr.id, :private=>true
  end

  def messages_to usr
    microposts.messages.where(:in_reply_to => usr.id)
  end

  def messages_from usr
    usr.microposts.messages.where(:in_reply_to => self.id)
  end

  def messages_to_or_from usr
    Micropost.messages.between usr, self
  end
  alias conversation_with messages_to_or_from

  # MME generates a unique login name for a user
  def pseudo_login_name
    name.downcase.split.join("_")+"_"+ id.to_s
  end

  # MME generate, remove and find_by password_reminders and activation_tokens
  # MME creates a password reminder if it doesn't yet exist
  def generate_password_reminder
    create_password_reminder!(:token=>SecureRandom.hex(32)) unless password_reminder
  end

  # MME removes if exists
  def remove_password_reminder
    password_reminder.delete if password_reminder
  end

  # finds a user from a token
  def self.find_by_password_reminder(token)
    pr=PasswordReminder.find_by_token(token, :include=>:user)
    pr.user if pr
  end

  def generate_activation_token
    create_activation_token!(:token=>SecureRandom.hex(32)) unless activation_token
  end

  def remove_activation_token
    activation_token.delete if activation_token
  end

  def self.find_by_activation_token(token)
    at=ActivationToken.find_by_token(token, :include=>:user)
    at.user if at
  end

  # MME finds a user from a pseudo_login_name
  # first tries to get it from an id
  # last tries to get it from a name
  def self.find_by_pseudo_login_name(pln)
    nam=pln.split("_")
    id = nam.last.to_i
    if id>0 # First attempt: if it exists an id as the last part off the pln 
      User.find_by_id(id)
    else # Second attempt: try to generate a name from a pln
      User.find_by_name(nam.map(&:capitalize).join(" "))
    end
  end

  # FUNCIONS PRIVADES
  private

    def encrypt_password
      self.salt = make_salt unless has_password?(password)	# self.salt resets everytime user changes its password
      self.encrypted_password = encrypt(password)	# password refers to self.password
    end

    def make_salt
      Digest::SHA2.hexdigest "#{Time.now.utc}--#{password}"
    end

    def encrypt(str)
      Digest::SHA2.hexdigest "#{salt}--#{str}"
    end

    # salva nomes la columna state (evitant callbacks i validations)
    def save_state
      update_column 'state', state
    end

end

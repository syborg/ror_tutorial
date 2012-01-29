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

# MME per a utilitzar les Hash functions
require 'digest'

class User < ActiveRecord::Base

	attr_accessor :password

	# MME si es posa, atributs (columnes) als que es podrà accedir via ActiveRecord
	attr_accessible	:name, :email, :password, :password_confirmation
	# MME validacions
	validates :name, :presence => true, 
					 :length=> {maximum: 50}

	validates :email, :presence => true, 
					  :format => { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
					  :uniqueness => { :case_sensitive => false}

	validates :password, :presence => true,
                         :confirmation => true,	# crea un atribut password_confirmation i a la vegad confirma que sigui igual que password
                         :length => { :within => 6..40 }

    validates :password_confirmation, :presence => true	# MME aixo exigigeix que al crear es passi un :password_confirmation, doncs amb nomes
    													#	  l'anterior validator sol, pot crearse un usuari si no es passa :password_confirmation
					 
	before_save :encrypt_password

	has_many :microposts

	# Torna l'User de l'email si el password es correcte
	def self.authenticate(email, submited_pwd)
		if usr = find_by_email(email)
			usr.has_password?(submited_pwd) ? usr : nil
		else
			nil
		end
	end

	# verifica si el password correspon a l'User
	def has_password?(submited_pwd)
		self.encrypted_password == encrypt(submited_pwd)
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

end

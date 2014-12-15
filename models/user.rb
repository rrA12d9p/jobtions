require "bcrypt"
# require_relative "../db/connection"

class User < ActiveRecord::Base
	# attributes
  attr_accessor :password, :password_confirmation

  # callbacks
  before_save :encrypt_password

	# validations
  # validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates :username,
    :presence => true,
    :length => { maximum: 255 },
    :uniqueness => { case_sensitive: false }
  validates :zipcode,
    :length => { minimum: 5 }
  validates :email,
    :presence => true,
    :uniqueness => { case_sensitive: false },
    :length => { maximum: 255 },
    :format => { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

	# relationships
	has_one :job
  has_one :personality

	# methods
  def authenticate(password)
    if BCrypt::Password.new(self.password_digest) == password
      return true
    else
      return false
    end
  end

  def encrypt_password
    if password.present?
      return self.password_digest = BCrypt::Password.create(password)
    end
  end

end
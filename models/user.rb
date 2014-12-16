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
  def get_similarity(user2)
    user1 = self
    return false if !user1.is_a?(User) || !user2.is_a?(User)

    compare_traits = [:extraversion, :agreeableness, :conscientiousness, :emotional_stability, :intellect_imagination]

    sum_diffs = 0

    compare_traits.each do |t|
      # check that both users have all the required traits
      return false if !user1.personality.respond_to?(t) || !user2.personality.respond_to?(t)
      
      user1_t_val = user1.personality.send(t).to_i
      user2_t_val = user2.personality.send(t).to_i

      # compare the percentage scores for each user per category
      # add the diff (0-100) to sum_diffs
      diff = (user1_t_val - user2_t_val).abs
      sum_diffs += diff
    end

    # 100% different should have a similarity of 0 and vice-versa
    similarity = 100 - (sum_diffs / compare_traits.length)

    return similarity
  end

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
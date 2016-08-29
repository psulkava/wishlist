class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    upper = /(?=[A-Z])/
    lower = /(?=[a-z])/
    number = /(?=[0-9])/
    special = /(?=[^A-Za-z0-9])/
    count = 0;
    if value =~ upper then count += 1 end
    if value =~ lower then count += 1 end
    if value =~ number then count += 1 end
    if value =~ special then count += 1 end
    if count < 3
      record.errors[attribute] << ("is not secure enough, must have at least 3 of the following:
                                    lowercase letter, uppercase letter,
                                    number, or symbol")
    end
  end
end

class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 40 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 },
                        :password => true
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end

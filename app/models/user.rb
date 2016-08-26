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
      record.errors[attribute] << ("password is not secure enough")
    end
  end
end

class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 40 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 },
                        :password => true
end

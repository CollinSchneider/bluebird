class User < ActiveRecord::Base
  has_secure_password

  validates :password, presence: true
  validates :email, presence: true

  has_many :products
  has_many :commits
end

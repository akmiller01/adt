class User < ActiveRecord::Base
  
  attr_accessible :email, :name, 
  :password, :password_confirmation,
  :owner, :owner_id
  
  has_secure_password
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, format: {with: EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  belongs_to :owner, class_name: "Organization"


private 

  def create_remember_token
	 self.remember_token = SecureRandom.urlsafe_base64
	end

end

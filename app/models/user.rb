class User < ApplicationRecord
  has_secure_password

  has_many :body_temperatures, dependent: :destroy

  before_save :downcase_email

  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :password, presence: true, allow_nil: true

  scope :sorted, -> { order(id: :asc) }

  private

  def downcase_email
    self.email = email.downcase
  end
end

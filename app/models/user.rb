class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :omni_auth_identities, dependent: :destroy

  validates :email_address, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :password, on: [ :registration, :password_change ],
            presence: true,
            length: { minimum: 8, maximum: 72 }

  normalizes :email_address, with: ->(e) { e.strip.downcase }


  def self.create_from_oauth(auth)
    email = auth.info.email
    user = self.new email_address: email, password: SecureRandom.base64(64).truncate_bytes(64)
    user.assign_name_from_auth(auth)
    user.save
    user
  end

  def signed_in_with_oauth(auth)
    assign_name_from_auth(auth)
    save if name_changed?
  end

  def assign_name_from_auth(auth)
    self.name = auth.info.name if auth.info.name.present?
  end
end

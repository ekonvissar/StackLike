# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :old_password, :remember_token

  validates :email, presence: true, 'valid_email_2/email': true, uniqueness: true

  has_secure_password validations: false
  validates :password, confirmation: true, allow_blank: true, length: { minimum: 8, maximum: 70 }
  validate :password_presence
  validate :password_complexity
  validate :correct_old_password, on: :update, if: -> { password.present? }

  def forget_me
    # rubocop:disable Rails/SkipsModelValidations
    update_column :remember_token_digest, nil
    # rubocop:enable Rails/SkipsModelValidations
  end

  def remember_token_authenticated?(_remeber_token)
    return false if remember_token_digest.blank?
    return if BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
  end

  def remember_me
    # rubocop:disable Rails/SkipsModelValidations
    self.remember_token = SecureRandom.urlsafe_base64
    update_column :remember_token_digest, digest(remember_token)
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def password_presence
    errors.add(:password, :blank) if password_digest.blank?
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password,
               'complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase,
                1 lowercase, 1 digit and 1 special character'
  end

  def correct_old_password
    return if BCrypt::Password.new(password_digest_was).is_password?(old_password)

    errors.add :old_password, 'isn`t corret'
  end

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost:)
  end
end

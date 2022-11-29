# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern
  # rubocop:disable Metrics/BlockLength
  included do
    private

    def current_user
      user = session[:user_id].present? ? user_from_session : user_from_token
      @current_user ||= user.decorate
    end

    def user_from_session
      User.find_by(id: session[:user_id])
    end

    def user_from_token
      user = User.find_by(cookies.encrypted[:user_id])
      return unless user&.remember_token_authenticated?(cookies.encrypted[:remeber_token])

      sign_in user
      user
    end

    def user_signed_in?
      current_user.present?
    end

    def sign_in(user)
      session[:user_id] = user.id
    end

    def sign_out
      forget current_user
      session.delete  :user_id
      @current_user = nil
    end

    def require_no_authenticate
      return unless user_signed_in?

      flash[:danger] = 'You are already registred!'
      redirect_to root_path
    end

    def require_authenticate
      return if user_signed_in?

      flash[:danger] = 'You are not registred yet!'
      redirect_to root_path
    end

    def remember(user)
      user.remember_me
      cookies.encrypted.permanent[:remeber_token] = user.remember_token
      cookies.encrypted.permanent[:user] = user.id
    end

    def forget(user)
      user.forget_me
      cookies.delete :user_id
      cookies.delete :remember_token
    end

    helper_method :current_user, :user_signed_in?
  end
  # rubocop:enable Metrics/BlockLength
end

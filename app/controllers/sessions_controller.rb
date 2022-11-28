class SessionsController < ApplicationController
  before_action :require_no_authenticate, only: [:new, :create]
  before_action :require_authenticate, only: [:destroy]

  def new
  end

  def create
    user  = User.find_by email: params[:email]
    if user&.authenticate(params[:password])
      sign_in user
      remember(user) if params[:remember_me] == '1'
      flash[:success] = "Welcome back, #{current_user.name_or_email}"
      redirect_to root_path
    else
      flash[:danger] = 'Incorrect email or password'
      redirect_to new_session_path
    end
  end

  def destroy
    sign_out
    flash[:success] = "See you later!"
    redirect_to root_path
  end
  
end

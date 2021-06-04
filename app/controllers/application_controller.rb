class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  before_action :login_required

  private

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def login_required
    redirect_to login_url unless logged_in?
  end
end

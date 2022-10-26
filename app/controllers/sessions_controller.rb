class SessionsController < ApplicationController
  skip_before_action :login_required

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      session_params[:remember_cookies] == '1' ? store_remember_cookies(user) : release_remember_cookies(user)
      redirect_to root_url, notice: 'ログインしました。'
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが間違っています。'
      render :new
    end
  end

  def new
    if logged_in?
      redirect_to root_url
    else
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url, notice: 'ログアウトしました。'
  end

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember_cookies)
  end
end

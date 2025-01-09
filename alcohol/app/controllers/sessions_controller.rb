# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      if user.activated?
        session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
      else
        message = 'アカウントは有効化されていません。有効化リンクにアクセスしてください。'
        flash[:warning] = message
      end
      redirect_to root_url
    else
      flash.now[:danger] = 'メールアドレスまたはパスワードが間違っています。'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end

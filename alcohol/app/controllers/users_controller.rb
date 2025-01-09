# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user,   only: %i[show edit update]
  before_action :admin_user,     only: %i[index destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # reset_session
      # log_in @user
      # flash[:success] = "ユーザが登録されました。"
      # redirect_to root_url, status: :see_other
      @user.send_activation_email
      flash[:info] = 'メールをご確認の上、アカウントを有効化してください。'
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'プロフィールが更新されました。'
      redirect_to root_url, status: :see_other
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy!
    flash[:success] = 'ユーザーが削除されました。'
    redirect_to root_url, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

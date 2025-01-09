# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'noreply@example.com'

  def account_activation(user)
    @user = user
    mail to: user.email, subject: '【泥酔ストッパー】アカウント有効化依頼'
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: '【泥酔ストッパー】パスワード再設定用メール'
  end
end

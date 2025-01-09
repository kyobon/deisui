# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  # アカウントの有効化テスト
  test 'account_activation' do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal '【泥酔ストッパー】アカウント有効化依頼', mail.subject
    assert_equal [user.email], mail.to
    assert_equal ['phineas8290@gmail.com'], mail.from
    assert_match user.name,               mail.html_part.decoded
    assert_match user.activation_token,   mail.html_part.decoded
    assert_match CGI.escape(user.email),  mail.html_part.decoded
    assert_match user.name,               mail.text_part.decoded
    assert_match user.activation_token,   mail.text_part.decoded
    assert_match CGI.escape(user.email),  mail.text_part.decoded
  end

  # パスワード再設定のテスト
  test 'password_reset' do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal '【泥酔ストッパー】パスワード再設定用メール', mail.subject
    assert_equal [user.email], mail.to
    assert_equal ['phineas8290@gmail.com'], mail.from
    assert_match user.name,               mail.html_part.decoded
    assert_match user.reset_token,        mail.html_part.decoded
    assert_match CGI.escape(user.email),  mail.html_part.decoded
    assert_match user.name,               mail.text_part.decoded
    assert_match user.reset_token, mail.text_part.decoded
    assert_match CGI.escape(user.email), mail.text_part.decoded
  end
end

# frozen_string_literal: true

require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLoginTest
  # #無効な認証情報でログインを試みた場合失敗し、想定通りのページに遷移することを確認
  test 'login with valid email/invalid password' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: @user.email,
                                          password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLoginTest
  # #有効な認証情報でログイン
  def setup
    super
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  # 有効な認証情報でログインを試みた場合成功し、想定通りのページに遷移することを確認
  # その後、ログアウトした場合に想定通りの動作をすることを確認
  test 'login with valid information followed by logout' do
    assert is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'static_pages/top'
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', new_record_path, count: 2
    assert_select 'a[href=?]', limits_path, count: 2
    assert_select 'a[href=?]', edit_user_path(@user), count: 2
    assert_select 'a[href=?]', logout_path, count: 2
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', login_path, count: 3
    assert_select 'a[href=?]', record_path, count: 0
    assert_select 'a[href=?]', limits_path, count: 0
    assert_select 'a[href=?]', edit_user_path(@user), count: 0
    assert_select 'a[href=?]', logout_path, count: 0
  end
end

class RememberingTest < UsersLoginTest
  # Remember meを有効化した場合、Cookieにremember_tokenが設定されることを確認
  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  # Remember meを無効化した場合、Cookieからremember_tokenが削除されることを確認
  test 'login without remembering' do
    # Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    # Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end

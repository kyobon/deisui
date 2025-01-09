require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class ForgotPasswordFormTest < PasswordResets

  # パスワード再設定ページが正しく表示されるかどうかの確認
  test "password reset path" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  # 無効なメールアドレスでパスワード再設定をリクエストした場合の挙動を確認
  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
    assert_equal "メールアドレスが見つかりません。", flash[:danger]
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  # 有効なメールアドレスでパスワード再設定をリクエストした場合の挙動を確認
  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    assert_equal "パスワード再設定用メールが送信されました。", flash[:info]
  end

  # 誤ったメールアドレスでパスワード再設定をリクエストした場合の挙動
  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  # 有効化されていないユーザでパスワード再設定をリクエストした場合の挙動
  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  # 有効なメールアドレスと誤ったトークンでパスワード再設定をリクエストした場合の挙動
  test "reset with right email but wrong token" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  # 有効なメールアドレスと有効なトークンパスワード再設定をリクエストした場合の挙動
  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  # 不正なパスワードでパスワード再設定をリクエストした場合の挙動
  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  # パスワードが空欄の状態でパスワード再設定をリクエストした場合の挙動
  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  # 有効なパスワードでパスワード再設定をリクエストした場合の挙動
  test "update with valid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "password",
                            password_confirmation: "password" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to root_url
  end
end

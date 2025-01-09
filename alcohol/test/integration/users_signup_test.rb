require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  #無効なユーザ情報の場合、登録処理が行われず、users/newテンプレートに返されることを確認
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "hahaha",
                                         password_confirmation: "hohoho" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
  end

  #有効なユーザ情報の場合、登録処理が行われることを確認
  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal "メールをご確認の上、アカウントを有効化してください。", flash[:info]
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    @user = assigns(:user)
  end

  #新規ユーザー登録後、アカウントはデフォルトで有効化されていないことを確認
  test "should not be activated" do
    assert_not @user.activated?
  end

  #有効化されていないアカウントでログインを試みた場合、ログインが拒否されることを確認
  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
    assert_equal "アカウントは有効化されていません。有効化リンクにアクセスしてください。", flash[:warning]
  end

  #無効なアクティベーショントークンを使用してアカウント有効化を試みた場合、ログインが拒否されることを確認
  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
    assert_equal "有効化リンクが無効です。", flash[:danger]
  end

  #正しいアクティベーショントークンを提供しても、対応するemailが一致しない場合、ログインが拒否されることを確認
  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    assert_equal "有効化リンクが無効です。", flash[:danger]
  end

  #アカウントの有効化を行った場合、static_pages/topテンプレートに返され、ログイン状態であることを確認
  test "valid signup information" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    follow_redirect!
    assert_template 'static_pages/top'
    assert is_logged_in?
    assert_not flash.empty?
    assert_equal "アカウントが有効化されました。", flash[:success]
  end
end

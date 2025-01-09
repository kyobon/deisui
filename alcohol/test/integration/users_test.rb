require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  #テストユーザの作成
  def setup
    @user = users(:michael)
  end
end

class AdminUserTest < ActionDispatch::IntegrationTest
  #テストユーザの作成
  def setup
    @admin_user = users(:bob)
  end
end

class LoginPageControllerTest < UsersTest
  #新規登録ページへのGetアクセスが可能なことを確認
  test "GET access to signup_path" do
    get signup_path
    assert_response :success
  end

  #未ログイン状態のページの状態が正しいことを確認
  test "layout links without login" do
    get root_path
    assert_template 'static_pages/top'
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", login_path, count: 3
    assert_select "a[href=?]", signup_path
  end

  #一般ユーザのログイン状態のページの状態が正しいことを確認
  test "layout links with general user login" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/top'
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", new_record_path, count: 2
    assert_select "a[href=?]", limits_path, count: 2
    assert_select "a[href=?]", edit_user_path(@user), count: 2
    assert_select "a[href=?]", logout_path, count: 2
    assert_select "a[href=?]", users_path, count: 0
  end

  #ログイン状態でユーザ編集ページに移動し、編集できることを確認
  test "GET access to edit_user_path(@user)" do
    log_in_as(@user)
    get edit_user_path(@user)	
    assert_response :success
    patch user_path(@user), params: { user: { name: 'Alex', email: @user.email, password: 'password', password_confirmation: 'password' } }
    assert_redirected_to root_url
  end
end

class AdminLoginPageControllerTest < AdminUserTest
  #一般ユーザの作成
  def setup
    super
    @user = users(:michael)
  end

  #管理者ユーザのログイン状態のページの状態が正しいことを確認
  test "layout links with admin user login" do
    log_in_as(@admin_user)
    get root_path
    assert_template 'static_pages/top'
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", new_record_path, count: 2
    assert_select "a[href=?]", limits_path, count: 2
    assert_select "a[href=?]", edit_user_path(@admin_user), count: 2
    assert_select "a[href=?]", logout_path, count: 2
    assert_select "a[href=?]", users_path, count: 2
  end

  #ログイン状態の管理者ユーザでユーザ一覧ページに移動し、ユーザを削除できることを確認
  test "GET access to users_path" do
    log_in_as(@admin_user)
    get users_path
    assert_response :success
    assert_select "a[href=?]", user_path(@user), text: "削除"
    delete user_path(@user)
    assert_select "a[href=?]", user_path(@user), text: "削除", count: 0
    assert_redirected_to root_url
  end
end

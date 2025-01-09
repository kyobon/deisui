require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  #テストユーザの作成
  def setup
    @user = users(:michael)
    @user.save
  end

  #ログインしていない状態でユーザ一覧ページに移動できないことを確認
  test "Cannnot GET access to users_path" do
    get users_path
    assert_redirected_to login_path
  end

  #ログインしていない状態でユーザ編集ページに移動できないことを確認
  test "Cannnot GET access to edit_user_path(@user)	" do
    get edit_user_path(@user)	
    assert_redirected_to login_path
  end

  #ログイン状態の一般ユーザでユーザ一覧ページに移動できないことを確認
  test "Cannnot GET access to users_path by general user" do
    post login_path, params: { session: { email: @user.email, password: "password" } }
    get users_path
    assert_redirected_to root_path
  end

end
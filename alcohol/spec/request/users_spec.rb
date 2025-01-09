require "rails_helper"

RSpec.describe "Users", type: :request do
  # テストユーザの作成
  before do
    @user = create(:user, :michael)
    @admin_user = create(:user, :bob)
  end

  # ログインしていない状態でユーザ一覧ページに移動できないことを確認
  it "cannot GET access to users_path" do
    get users_path
    expect(response).to redirect_to(login_path)
  end

  # ログインしていない状態でユーザ編集ページに移動できないことを確認
  it "cannot GET access to edit_user_path(@user)" do
    get edit_user_path(@user), params: { id: @user.id }
    expect(response).to redirect_to(login_path)
  end

  # ログイン状態の一般ユーザでユーザ一覧ページに移動できないことを確認
  it "cannot GET access to users_path by general user" do
    log_in_as(@user)
    get users_path
    expect(response).to redirect_to(root_path)
  end

  # 新規登録ページへのGetアクセスが可能なことを確認
  it "GET access to signup_path" do
    get signup_path
    expect(response).to have_http_status(:success)
  end

  # 未ログイン状態のページの状態が正しいことを確認
  it "layout links without login" do
    get root_path
    expect(response).to render_template('static_pages/top')
    expect(response.body).to include(root_path)
    expect(response.body).to include(login_path)
    expect(response.body).to include(signup_path)
  end

  # 一般ユーザのログイン状態のページの状態が正しいことを確認
  it "layout links with general user login" do
    log_in_as(@user)
    get root_path
    expect(response).to render_template('static_pages/top')
    expect(response.body).to include(root_path)
    expect(response.body).to include(new_record_path)
    expect(response.body).to include(limits_path)
    expect(response.body).to include(edit_user_path(@user))
    expect(response.body).to include(logout_path)
  end

  # ログイン状態でユーザ編集ページに移動し、編集できることを確認
  it "GET access to edit_user_path(@user)" do
    log_in_as(@user)
    get edit_user_path(@user)
    expect(response).to have_http_status(:success)
    patch user_path(@user), params: { user: { name: 'Alex', email: @user.email, password: 'password', password_confirmation: 'password' } }
    expect(response).to redirect_to(root_url)
  end

  # 管理者ユーザのログイン状態のページの状態が正しいことを確認
  it "layout links with admin user login" do
    log_in_as(@admin_user)
    get root_path
    expect(response).to render_template('static_pages/top')
    expect(response.body).to include(root_path)
    expect(response.body).to include(new_record_path)
    expect(response.body).to include(limits_path)
    expect(response.body).to include(edit_user_path(@admin_user))
    expect(response.body).to include(logout_path)
    expect(response.body).to include(users_path)
  end

  # ログイン状態の管理者ユーザでユーザ一覧ページに移動し、ユーザを削除できることを確認
  it "GET access to users_path" do
    log_in_as(@admin_user)
    get users_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include(user_path(@user))
    delete user_path(@user)
    expect(response.body).not_to include(user_path(@user))
    expect(response).to redirect_to(root_url)
  end
end

RSpec.describe "User Signups", type: :request do
  before do
      ActionMailer::Base.deliveries.clear
  end

  #無効なユーザ情報の場合、登録処理が行われず、users/newテンプレートに返されることを確認
  it "invalid signup information" do
    get signup_path
    expect {
        post users_path, params: { user: { name:  "", email: "user@invalid", password: "hahaha", password_confirmation: "hohoho" } }
    }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response).to render_template('users/new')
  end

  #有効なユーザ情報の場合、登録処理が行われることを確認
  it "valid signup information with account activation" do
      expect {
          post users_path, params: { user: { name:  "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
      }.to change(User, :count).by(1)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(flash[:info]).to eq("メールをご確認の上、アカウントを有効化してください。")
  end
end

RSpec.describe "Account Activations", type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    post users_path, params: { user: { name:  "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
    @user = assigns(:user)
  end

  #新規ユーザー登録後、アカウントはデフォルトで有効化されていないことを確認
  it "should not be activated" do
    expect(@user).not_to be_activated
  end

  #有効化されていないアカウントでログインを試みた場合、ログインが拒否されることを確認
  it "should not be able to log in before account activation" do
    log_in_as(@user)
    expect(is_logged_in?).to be_falsey
    expect(flash[:warning]).to eq("アカウントは有効化されていません。有効化リンクにアクセスしてください。")
  end

  #無効なアクティベーショントークンを使用してアカウント有効化を試みた場合、ログインが拒否されることを確認
  it "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    expect(is_logged_in?).to be_falsey
    expect(flash[:danger]).to eq("有効化リンクが無効です。")
  end

  #正しいアクティベーショントークンを提供しても、対応するemailが一致しない場合、ログインが拒否されることを確認
  it "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    expect(is_logged_in?).to be_falsey
    expect(flash[:danger]).to eq("有効化リンクが無効です。")
  end

  #アカウントの有効化を行った場合、static_pages/topテンプレートに返され、ログイン状態であることを確認
  it "valid signup information" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    follow_redirect!
    expect(response).to render_template('static_pages/top')
    expect(is_logged_in?).to be_truthy
    expect(flash[:success]).to eq("アカウントが有効化されました。")
  end
end
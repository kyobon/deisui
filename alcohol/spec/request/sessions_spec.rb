require "rails_helper"

RSpec.describe "UsersLogin", type: :request do
  before do
    @user = create(:user, :michael)
  end

  # ログインページへのGetアクセスが可能なことを確認
  it "returns http success" do
    get login_path
    expect(response).to have_http_status(:success)
  end

  ##無効な認証情報でログインを試みた場合失敗し、想定通りのページに遷移することを確認
  it "login with valid email/invalid password" do
    get login_path
    expect(response).to render_template('sessions/new')
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    expect(is_logged_in?).to be_falsey
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response).to render_template('sessions/new')
    expect(flash).not_to be_empty
    get root_path
    expect(flash).to be_empty
  end

  describe "ValidLogin" do
    #有効な認証情報でログイン
    before do
      post login_path, params: { session: { email: @user.email, password: 'password' } }
    end

    #有効な認証情報でログインを試みた場合成功し、想定通りのページに遷移することを確認
    #その後、ログアウトした場合に想定通りの動作をすることを確認
    it "login with valid information followed by logout" do
      expect(is_logged_in?).to be_truthy
      expect(response).to redirect_to(root_url)
      follow_redirect!
      expect(response).to render_template('static_pages/top')
      expect(response.body).to include(root_path)
      expect(response.body).to include(new_record_path)
      expect(response.body).to include(limits_path)
      expect(response.body).to include(edit_user_path(@user))
      expect(response.body).to include(logout_path)
      delete logout_path
      expect(is_logged_in?).to be_falsey
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_url)
      follow_redirect!
      expect(response.body).to include(root_path)
      expect(response.body).to include(signup_path)
      expect(response.body).to include(login_path)
      expect(response.body).not_to include(record_path)
      expect(response.body).not_to include(limits_path)
      expect(response.body).not_to include(edit_user_path(@user))
      expect(response.body).not_to include(logout_path)
    end
  end

  #Remember meを有効化した場合、Cookieにremember_tokenが設定されることを確認
  it "login with remembering" do
    log_in_as(@user, remember_me: '1')
    expect(cookies[:remember_token]).not_to be_blank
  end

  #Remember meを無効化した場合、Cookieからremember_tokenが削除されることを確認
  it "login without remembering" do
    log_in_as(@user, remember_me: '1')
    log_in_as(@user, remember_me: '0')
    expect(cookies[:remember_token]).to be_blank
  end
end

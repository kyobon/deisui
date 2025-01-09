require "rails_helper"

RSpec.describe "PasswordResets", type: :request do

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "ResetPasswordPageView" do

    # パスワード再設定ページが正しく表示されるかどうかの確認
    it "password reset path" do
      get new_password_reset_path
      expect(response).to render_template('password_resets/new')
      expect(response).to have_http_status(:success)
    end

    # 無効なメールアドレスでパスワード再設定依頼を行った場合の挙動を確認
    it "reset path with invalid email" do
      post password_resets_path, params: { password_reset: { email: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:danger]).to eq "メールアドレスが見つかりません。"
      expect(response).to render_template('password_resets/new')
    end
  end

  describe "ResetPasswordAction" do
    let(:user) { create(:user, :michael) }
    let(:reset_user) { assigns(:user) }

    before do
      post password_resets_path, params: { password_reset: { email: user.email } }
    end

    # 有効なメールアドレスでパスワード再設定依頼を行った場合の挙動を確認
    it "reset with valid email" do
      expect(user.reset_digest).not_to eq reset_user.reset_digest
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(flash[:info]).to eq "パスワード再設定用メールが送信されました。"
      expect(response).to redirect_to(root_url)
    end

    # 有効化されていないユーザでパスワード再設定用ページにアクセスした場合の挙動
    it "reset with inactive user" do
      reset_user.toggle!(:activated)
      get edit_password_reset_path(reset_user.reset_token, email: reset_user.email)
      expect(response).to redirect_to(root_url)
    end

    # 誤ったメールアドレスでパスワード再設定用ページにアクセスした場合の挙動
    it "reset with wrong email" do
      get edit_password_reset_path(reset_user.reset_token, email: "")
      expect(response).to redirect_to(root_url)
    end

    # 有効なメールアドレスと誤ったトークンでパスワード再設定用ページにアクセスした場合の挙動
    it "reset with right email but wrong token" do
      get edit_password_reset_path('wrong token', email: reset_user.email)
      expect(response).to redirect_to(root_url)
    end

    # 有効なメールアドレスと有効なトークンパスワード再設定用ページにアクセスした場合の挙動
    it "reset with right email and right token" do
      get edit_password_reset_path(reset_user.reset_token, email: reset_user.email)
      expect(response).to render_template('password_resets/edit')
      expect(response).to have_http_status(:success)
    end

    # 不正なパスワードでパスワード再設定を実行した場合の挙動
    it "update with invalid password and confirmation" do
      patch password_reset_path(reset_user.reset_token),
            params: { email: reset_user.email,
                      user: { password: "foobaz", password_confirmation: "barquux" } }
      expect(response.body).to include('div id="error_explanation"')
    end

    # パスワードが空欄の状態でパスワード再設定を実行した場合の挙動
    it "update with empty password" do
      patch password_reset_path(reset_user.reset_token),
            params: { email: reset_user.email,
                      user: { password: "", password_confirmation: "" } }
      expect(response.body).to include('div id="error_explanation"')
    end

    # 有効なパスワードでパスワード再設定を実行した場合の挙動
    it "update with valid password and confirmation" do
      patch password_reset_path(reset_user.reset_token),
            params: { email: reset_user.email,
                      user: { password: "password", password_confirmation: "password" } }
      expect(is_logged_in?).to be_truthy
      expect(flash[:success]).not_to be_empty
      expect(response).to redirect_to(root_url)
    end
  end
end

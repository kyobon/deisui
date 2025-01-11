require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    # ユーザーオブジェクトを新規作成し、名前、メールアドレス、パスワード、およびパスワード確認を設定します。
    @user = User.new(name: "Example User", email: "user@example.com", password: "testpassword", password_confirmation: "testpassword")
  end

  # ユーザーが有効であることを確認する
  it "should be valid" do
    expect(@user).to be_valid
  end

  #ユーザ名の存在性を確認
  it "name should be present" do
    @user.name = ""
    expect(@user).not_to be_valid
    expect(@user.errors[:name]).to include("名前を入力してください。")
  end

  #Eメールの存在性を確認
  it "email should be present" do
    @user.email = "     "
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to include("メールアドレスを入力してください。")
  end

  #パスワードの存在性を確認
  it "password should be present" do
    @user.password = "     "
    expect(@user).not_to be_valid
    expect(@user.errors[:password]).to include("パスワードを入力してください。")
  end

  #確認用パスワードの存在性を確認
  it "password_confirmation should be present" do
    @user.password_confirmation = "     "
    expect(@user).not_to be_valid
    expect(@user.errors[:password_confirmation]).to include("確認用パスワードを入力してください。")
  end

  #ユーザ名の長さの最大が50であることを確認
  it "name should not be too long" do
    @user.name = "a" * 47
    expect(@user).not_to be_valid
    expect(@user.errors[:name]).to include("名前は50文字以下にしてください。")
  end

  #メールアドレスの長さの最大が255であることを確認
  it "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to include("メールアドレスは255文字以下にしてください。")
  end

  #パスワードの長さの最小が8であることを確認
  it "password should not be too short" do
    @user.password = "testaaa"
    expect(@user).not_to be_valid
    expect(@user.errors[:password]).to include("パスワードは8文字以上にしてください。")
  end

  #Eメールが正しいフォーマットで入力された場合、登録されることを確認
  it "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      expect(@user).to be_valid, "#{valid_address.inspect} should be valid"
    end
  end

  #Eメールが正しいフォーマットで登録されていない場合拒否されることを確認
  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                                                    foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      expect(@user).not_to be_valid, "#{invalid_address.inspect} should be invalid"
    end
    expect(@user.errors[:email]).to include("有効なメールアドレスを入力してください。")
  end

  # メールアドレスが一意であることを確認
  it "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    expect(duplicate_user).not_to be_valid
    expect(duplicate_user.errors[:email]).to include("このメールアドレスは既に登録されています。")
  end

  # メールアドレスが小文字として保存されることを確認
  it "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    expect(@user.reload.email).to eq mixed_case_email.downcase
  end

  #ユーザーのdigestが存在しない場合（例えばユーザーがログアウトしている状態）に、authenticated?メソッドがtrueを返さないことを確認
  it "authenticated? should return false for a user with nil digest" do
    expect(@user.authenticated?(:remember, '')).to be_falsey
  end
end
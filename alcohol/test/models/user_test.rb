# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # テスト用ユーザを準備
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'testpassword', password_confirmation: 'testpassword')
  end

  # ユーザの有効性を確認
  test 'should be valid' do
    assert @user.valid?
  end

  # ユーザ名の存在性を確認
  test 'name should be present' do
    @user.name = ''
    assert_not @user.valid?
    assert_includes @user.errors[:name], '名前を入力してください。'
  end

  # Eメールの存在性を確認
  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
    assert_includes @user.errors[:email], 'メールアドレスを入力してください。'
  end

  # パスワードの存在性を確認
  test 'password should be present' do
    @user.password = '     '
    assert_not @user.valid?
    assert_includes @user.errors[:password], 'パスワードを入力してください。'
  end

  # 確認用パスワードの存在性を確認
  test 'password_confirmation should be present' do
    @user.password_confirmation = '     '
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], '確認用パスワードを入力してください。'
  end

  # ユーザ名の長さの最大が50であることを確認
  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
    assert_includes @user.errors[:name], '名前は50文字以下にしてください。'
  end

  # メールアドレスの長さの最大が255であることを確認
  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"
    assert_not @user.valid?
    assert_includes @user.errors[:email], 'メールアドレスは255文字以下にしてください。'
  end

  # パスワードの長さの最小が8であることを確認
  test 'password should not be too long' do
    @user.password = 'testaaa'
    assert_not @user.valid?
    assert_includes @user.errors[:password], 'パスワードは8文字以上にしてください。'
  end

  # Eメールが正しいフォーマットで入力された場合、登録されることを確認
  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # Eメールが正しいフォーマットで登録されていない場合拒否されることを確認
  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
    assert_includes @user.errors[:email], '有効なメールアドレスを入力してください。'
  end

  # Eメールの一意性を確認
  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save!
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], 'このメールアドレスは既に登録されています。'
  end

  # Eメールが小文字で保存されることを確認
  test 'email addresses should be saved as lowercase' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save!
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # ユーザーのdigestが存在しない場合（例えばユーザーがログアウトしている状態）に、authenticated?メソッドがtrueを返さないことを確認
  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end
end

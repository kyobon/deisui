# frozen_string_literal: true

class User < ApplicationRecord
  has_many :records, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest
  has_secure_password
  validates :name, presence: { message: '名前を入力してください。' }, length: { maximum: 50, message: '名前は50文字以下にしてください。' }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: 'メールアドレスを入力してください。' },
                    length: { maximum: 255, message: 'メールアドレスは255文字以下にしてください。' },
                    format: { with: VALID_EMAIL_REGEX, message: '有効なメールアドレスを入力してください。', allow_blank: true },
                    uniqueness: { case_sensitive: false, message: 'このメールアドレスは既に登録されています。' }
  validates :password, presence: { message: 'パスワードを入力してください。' },
                       length: { minimum: 8, message: 'パスワードは8文字以上にしてください。' },
                       allow_nil: true
  validates :password_confirmation, presence: { message: '確認用パスワードを入力してください。' }, if: -> { password.present? }
  # パスワードと確認用パスワードが一致するかを確認
  validate :password_match, if: -> { password.present? && password_confirmation.present? }
  # 確認用パスワードのみが入力された場合はエラーを発生
  validate :only_password_confirmation, if: -> { password.blank? && password_confirmation.present? }

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost:)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # パスワードと確認用パスワードが一致するかを確認
  def password_match
    errors.add(:password_confirmation, 'パスワードと確認用パスワードが一致しません。') if password != password_confirmation
  end

  # 確認用パスワードのみが入力された場合はエラーを発生
  def only_password_confirmation
    errors.add(:password_confirmation, 'パスワードを入力してください。')
  end
end

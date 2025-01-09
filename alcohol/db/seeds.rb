# スーパーユーザーを1人作成する
User.create!(name:  ENV['SUPER_USER_NAME'],
             email: ENV['SUPER_USER_EMAIL'],
             password:              ENV['SUPER_USER_PASSWORD'],
             password_confirmation: ENV['SUPER_USER_PASSWORD'],
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

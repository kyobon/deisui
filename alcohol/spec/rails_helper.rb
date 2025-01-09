ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'factory_bot_rails'
require 'rspec/rails'
require 'capybara/rails'
require 'rails_helper'

# テスト環境がproductionでないことを確認
abort("The Rails environment is running in production mode!") if Rails.env.production?

# spec/support以下のファイルを自動で読み込む
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# マイグレーションがすべて適用されているか確認
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # specディレクトリ以下のテストファイルを自動で読み込む
  config.fixture_paths = "#{::Rails.root}/spec/fixtures"

  # ActiveRecordを使用する場合にトランザクションを利用する設定
  config.use_transactional_fixtures = true

  # 特定のRspecディレクトリ構造を自動生成
  config.infer_spec_type_from_file_location!

  # Railsのヘルパーを自動で読み込む
  config.filter_rails_from_backtrace!

  # FactoryBotの導入
  config.include FactoryBot::Syntax::Methods

  # TestHelpersをinclude
  config.include TestHelpers
  config.include IntegrationHelpers, type: :request # リクエストスペックに適用
end

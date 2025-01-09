# frozen_string_literal: true

require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # 未ログイン状態のページの状態が正しいことを確認（ログイン後の画面表示はusers_login）
  test 'layout links without login' do
    get root_path
    assert_template 'static_pages/top'
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', login_path, count: 3
    assert_select 'a[href=?]', signup_path
  end
end

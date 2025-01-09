# frozen_string_literal: true

require 'test_helper'

class RecordsControllerTest < ActionDispatch::IntegrationTest
  # ログインしていない状態でレコード新規作成ページに移動できないことを確認
  test 'Cannnot GET access to new_record_path' do
    get new_record_path
    assert_redirected_to login_path
    follow_redirect!
    assert_template 'sessions/new'
  end
end

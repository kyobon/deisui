# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # ログインページへのGetアクセスが可能なことを確認
  test 'GET access to login_path' do
    get login_path
    assert_response :success
  end
end

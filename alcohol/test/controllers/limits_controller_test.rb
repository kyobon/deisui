require "test_helper"

class LimitsControllerTest < ActionDispatch::IntegrationTest

  #ログインしていない状態でレポートのページに移動できないことを確認
  test "Cannnot GET access to limits_path" do
    get limits_path
    assert_redirected_to login_path
    follow_redirect!
    assert_template 'sessions/new'
  end

end

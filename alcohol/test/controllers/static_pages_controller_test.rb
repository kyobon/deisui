require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  #root_urlへのGetアクセス確認
  test "GET access to root_url" do
    get root_url
    assert_response :success
    assert_select "title", "泥酔ストッパー"
  end

  #top_pathへのGetアクセス確認
  test "GET access to top_path" do
    get top_path
    assert_response :success
  end
end

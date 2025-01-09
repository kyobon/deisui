require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  #root_urlへのGetアクセス確認
  it "returns a successful response" do
    get root_url
    expect(response).to have_http_status(:success)
    expect(response.body).to include("泥酔ストッパー")
    expect(response).to render_template('static_pages/top')
  end
  #top_pathへのGetアクセス確認
  it "returns a successful response" do
    get top_path
    expect(response).to have_http_status(:success)
  end
end

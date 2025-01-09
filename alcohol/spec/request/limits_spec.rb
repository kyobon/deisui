require 'rails_helper'

RSpec.describe "Limits", type: :request do

  #ログインしていない状態でレポートのページに移動できないことを確認
  it "cannot GET access to limits_path" do
    get limits_path
    expect(response).to redirect_to(login_path)
    follow_redirect!
    expect(response).to render_template('sessions/new')
  end

end

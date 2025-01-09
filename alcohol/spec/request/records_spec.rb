require "rails_helper"

RSpec.describe "Records", type: :request do
  # テストユーザの作成
  before do
    @user = create(:user, :michael)
    @drinking_record = Record.new(hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                         beer: 1000, highball: 0, chuhi: 0, sake: 0, wine: 0,
                         whiskey: 0, shochu: 0, drunk: "ほろ酔い",
                         user_id: @user.id)
    @drinking_record.toughness = calculate_toughness(@drinking_record)
    @drinking_record.save
  end

  # ログインしていない状態でレコード新規作成ページに移動できないことを確認
  it "cannot GET access to new_record_path" do
    get new_record_path
    expect(response).to redirect_to(login_path)
    follow_redirect!
    expect(response).to render_template('sessions/new')
  end

  # カレンダーページが表示されることを確認
  it "GET access to new_record_path" do
    log_in_as(@user)
    get new_record_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include('カレンダー')
  end

  # レコードの登録が正しく実行できることを確認
  it "Create new record" do
    log_in_as(@user)
    get new_record_path
    expect(response).to have_http_status(:success)

    expect {
      post records_path, params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 19),
                                             beer: 1500, highball: 0, chuhi: 0, sake: 0, wine: 0,
                                             whiskey: 0, shochu: 0, drunk: "ほろ酔い",
                                             user_id: @user.id}}
    }.to change(Record, :count).by(1)

    expect(response).to redirect_to(new_record_path)
    follow_redirect!
    expect(flash[:success]).to eq("飲酒が記録されました。")
    record = Record.first
    expect(record.user_id).to eq(@user.id)
    expect(record.drink_day).to eq(Date.new(2024, 11, 19))
    expect(record.beer).to eq(1500)
    expect(record.drunk).to eq("ほろ酔い")
  end

  # レコードの編集を正しく実行できることを確認
  it "Edit record" do
    log_in_as(@user)
    get new_record_path
    expect(response).to have_http_status(:success)
    expect(@drinking_record.beer).to eq(1000)
    expect(@drinking_record.drunk).to eq("ほろ酔い")

    patch update_record_records_path, params: {record: 
    { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
    beer: 1500, highball: 0, chuhi: 0, sake: 0, wine: 0,
    whiskey: 0, shochu: 0, drunk: "酔っ払った" }}

    expect(response).to redirect_to(new_record_path)
    follow_redirect!
    expect(flash[:success]).to eq("飲酒記録が更新されました。")
    @drinking_record.reload
    expect(@drinking_record.beer).to eq(1500)
    expect(@drinking_record.drunk).to eq("酔っ払った")
  end

  # レコードの削除を正しく実行できることを確認
  it "Delete record" do
    log_in_as(@user)
    get new_record_path
    expect(response).to have_http_status(:success)

    expect {
      delete destroy_record_records_path, 
      params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                          beer: 1000, highball: 0, chuhi: 0, sake: 0, wine: 0,
                          whiskey: 0, shochu: 0, drunk: "ほろ酔い",
                          user_id: @user.id}}
    }.to change(Record, :count).by(-1)

    expect(response).to redirect_to(new_record_path)
    follow_redirect!
    expect(flash[:success]).to eq("飲酒記録が削除されました。")
  end
end

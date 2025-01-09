require "rails_helper"

RSpec.describe Record, type: :model do
  # テスト用レコードを準備
  before do
    @user = create(:user, :michael)
    @record = Record.new(hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                         beer: 1000, highball: 0, chuhi: 0, sake: 0, wine: 0,
                         whiskey: 0, shochu: 0, drunk: "ふらふらする/呂律が回らない",
                         user_id: @user.id)
    @record.toughness = calculate_toughness(@record)
  end

  # レコードの有効性を確認
  it "is valid with valid attributes" do
    expect(@record).to be_valid
  end

  # user_idの存在性を確認
  it "is not valid without a user_id" do
    @record.user_id = nil
    expect(@record).not_to be_valid
  end

  # 飲み会時間に0時間0分を登録できないことを確認
  it "is not valid with a duration of 0 hours and 0 minutes" do
    @record.hours = 0
    expect(@record).not_to be_valid
  end

  # 飲酒量に0未満の数値を登録できないことを確認
  it "is not valid with a negative alcohol amount" do
    @record.beer = -2
    expect(@record).not_to be_valid
  end

  # 飲酒量を全てゼロとして登録できないことを確認
  it "is not valid with a total alcohol amount of 0" do
    @record.beer = 0
    expect(@record).not_to be_valid
  end
end

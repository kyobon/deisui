require "test_helper"

class RecordTest < ActiveSupport::TestCase
  #テスト用レコードを準備
  def setup
    @user = users(:michael)
    @user.save
    @record = Record.new(hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                         beer: 1000, highball: 0, chuhi: 0, sake: 0, wine: 0,
                         whiskey: 0, shochu: 0, drunk: "ふらふらする/呂律が回らない",
                         user_id: @user.id)
    toughness = calculate_toughness(@record)
    @record.toughness = calculate_toughness(@record)
  end

  #レコードの有効性を確認
  test "record should be valid" do
    assert @record.valid?, @record.errors.full_messages.join(", ")
  end

  #user_idの存在性を確認
  test "user_id should be present" do
    @record.user_id = ""
    assert_not @record.valid?
  end

  #飲み会時間に0時間0分を登録できないことを確認
  test "duration should not be 0" do
    @record.hours = 0
    assert_not @record.valid?
  end

  #飲酒量に0未満の数値を登録できないことを確認
  test "alcohol should not be negative value" do
    @record.beer = -2
    assert_not @record.valid?
  end

  #飲酒量を全てゼロとして登録できないことを確認
  test "Total alcohol amount should not be 0" do
    @record.beer = 0
    assert_not @record.valid?
  end
end

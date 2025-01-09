require "test_helper"

class RecordsTest < ActionDispatch::IntegrationTest
  fixtures :users, :records
  #テストユーザ、レコードの作成
  def setup
    @user = users(:shige)
    @user.save
    #飲み過ぎの日のレコードの作成
    @overdrinking_record = records(:overdrinking_record)
    toughness = calculate_toughness(@overdrinking_record)
    @overdrinking_record.toughness = calculate_toughness(@overdrinking_record)
    @overdrinking_record.save
  end

  #飲み会時間を選択する前は測定結果が「-」と表示されること
  test "GET access to limits_path" do
    log_in_as(@user)
    get limits_path
    assert_response :success

    assert_select '.limit__title-span', text: '測定結果'
    assert_select '.limit__alcohol', text: '-'
    assert_select '.limit__result-advise-content', text: '-'
  end
=begin
  #飲み会時間を選択した後は、測定結果に「-」が表示されないこと
  test "GET access to limits_path and select drinking time" do
    log_in_as(@user)
    # カレンダーのページにGETリクエストを送信
    get limits_path
    assert_response :success

    get limits_path, params: { drinking_hours: 2 }

    assert_select '.limit__title-span', text: '測定結果'
    assert_select '.limit__alcohol', text: '-', count: 0
    assert_select '.limit__result-advise-content', text: '-', count: 0
  end

  #飲み過ぎの日のレコードが存在しない場合は、飲み会時間を選択した場合も、測定結果に「-」が表示されること
  test "Delete record and GET access to limits_path and select drinking time" do
    #まず初めに飲み過ぎの日のレコードを削除
    log_in_as(@user)
    get new_record_path
    assert_response :success

    delete destroy_record_records_path(@overdrinking_record), 
    params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 14),
                        beer: 2500, highball: 0, chuhi: 0, sake: 0, wine: 0,
                        whiskey: 0, shochu: 0, drunk: "ふらふらする/呂律が回らない",
                        user_id: @user.id}}

    assert_redirected_to new_record_path
    assert_not flash.empty?
    assert_equal "飲酒記録が削除されました。", flash[:success]

    #飲み会時間を選択
    get limits_path
    assert_response :success
    get limits_path, params: { drinking_hours: 0.5 }

    #飲み過ぎの日のレコードが存在しない場合は、飲み会時間を選択した場合も、測定結果に「-」が表示されることを確認
    assert_select '.limit__title-span', text: '測定結果'
    assert_select '.limit__alcohol', text: '-'
    assert_select '.limit__result-advise-content', text: '-'
  end
=end
end

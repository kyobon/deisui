# frozen_string_literal: true

require 'test_helper'
# require 'capybara/rails'

class RecordsTest < ActionDispatch::IntegrationTest
  # include Capybara::DSL
  # テストユーザ、レコードの作成
  def setup
    @user = users(:michael)
    @user.save!
    # レコードの作成
    @drinking_record = records(:drinking_record)
    @drinking_record.save!
  end

  # カレンダーページが表示されることを確認
  test 'GET access to new_record_path' do
    log_in_as(@user)
    get new_record_path
    assert_response :success

    assert_select 'h3', 'カレンダー'
  end

  # レコードの登録が正しく実行できることを確認
  test 'Create new record' do
    log_in_as(@user)
    get new_record_path
    assert_response :success

    assert_difference 'Record.count', 1 do
      post records_path, params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 19),
                                             beer: 1500, highball: 0, chuhi: 0, sake: 0, wine: 0,
                                             whiskey: 0, shochu: 0, drunk: 'ほろ酔い',
                                             user_id: @user.id } }
    end

    assert_redirected_to new_record_path
    assert_not flash.empty?
    assert_equal '飲酒が記録されました。', flash[:success]
    # レコードが追加されていることを確認
    record = Record.first
    assert_equal @user.id, record.user_id
    assert_equal Date.new(2024, 11, 19), record.drink_day
    assert_equal 1500, record.beer
    assert_equal 'ほろ酔い', record.drunk
  end

  # レコードの編集を正しく実行できることを確認
  test 'Edit record' do
    log_in_as(@user)
    get new_record_path
    assert_response :success
    # レコードの値が更新前であることを確認
    assert_equal 1000, @drinking_record.beer
    assert_equal 'ほろ酔い', @drinking_record.drunk

    patch update_record_records_path(@drinking_record),
          params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                              beer: 1500, highball: 0, chuhi: 0, sake: 0, wine: 0,
                              whiskey: 0, shochu: 0, drunk: '酔っ払った',
                              user_id: @user.id } }

    assert_redirected_to new_record_path
    assert_not flash.empty?
    assert_equal '飲酒記録が更新されました。', flash[:success]
    # レコードの値が更新済みであることを確認
    @drinking_record.reload
    assert_equal 1500, @drinking_record.beer
    assert_equal '酔っ払った', @drinking_record.drunk
  end

  # レコードの削除を正しく実行できることを確認
  test 'Delete record' do
    log_in_as(@user)
    get new_record_path
    assert_response :success

    assert_difference 'Record.count', -1 do
      delete destroy_record_records_path(@drinking_record),
             params: { record: { hours: 2, minutes: 0, drink_day: Date.new(2024, 11, 9),
                                 beer: 1000, highball: 0, chuhi: 0, sake: 0, wine: 0,
                                 whiskey: 0, shochu: 0, drunk: 'ほろ酔い',
                                 user_id: @user.id } }
    end
    assert_redirected_to new_record_path
    assert_not flash.empty?
    assert_equal '飲酒記録が削除されました。', flash[:success]
  end
end

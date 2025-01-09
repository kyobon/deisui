# frozen_string_literal: true

class LimitsController < ApplicationController
  before_action :logged_in_user, only: [:index]
  include LimitsHelper

  def index
    # 現在のユーザのレコードを取得
    @user = User.find(current_user.id)
    @record = @user.records.all

    # #許容量算出

    # 許容量の算出に使用するレコードの酒の耐性のみを抽出（"ふらふらする/呂律が回らない"または"泥酔"の時のレコードのみを使用）
    lis = []
    @record.each do |r|
      lis.push(r.toughness) if r.drunk == 'ふらふらする/呂律が回らない' || r.drunk == '泥酔'
    end
    # 許容量の算出に使用するパラメータを準備
    limit_con = 1.5 # 限界血中アルコール濃度を1.5mg/mlと定義
    dec = 0.15 # アルコール減少率は0.15に固定（0.11〜0.19の間で個人差があるが、許容量の数値に対し支配的ではないため、一定値に固定）
    drinking_hours = params[:drinking_hours].to_f # 飲み会の時間を取得
    # レコードに"ふらふらする/呂律が回らない"または"泥酔"の日が含まれていない場合、@toughness_avgを0とする
    @toughness_avg = if lis.empty?
                       0
                     else
                       lis.sum.fdiv(lis.length).round
                     end
    # レコードに"ふらふらする/呂律が回らない","泥酔"の日が含まれていない場合、または飲み会時間が0の場合は算出しない
    @limit_alc = if drinking_hours.zero? || @toughness_avg.zero?
                   '-'
                 else
                   (limit_con + (drinking_hours * dec)) * @toughness_avg
                 end
    # #飲んで良い酒の量（杯数に換算）を取得する。
    limit_mugs = limit_mugs_number(@limit_alc) # limit_mugs_numberメソッドで飲んで良い酒の量（杯数に換算）を算出する。
    @beer_mugs = limit_mugs[:beer_mugs]
    @highball_mugs = limit_mugs[:highball_mugs]
    @chuhi_mugs = limit_mugs[:chuhi_mugs]
    @sake_mugs = limit_mugs[:sake_mugs]
    @wine_mugs = limit_mugs[:wine_mugs]
    @whiskey_mugs = limit_mugs[:whiskey_mugs]
    @shochu_mugs = limit_mugs[:shochu_mugs]

    # #今月の飲酒量算出

    # グラフ用のデータ準備 (日付 => 値 の形式)
    # 今日の年月をもとに月の初日と末日を取得
    start_date = Time.zone.today.beginning_of_month
    end_date = Time.zone.today.end_of_month
    # 今月の日付をキー、0を値とするハッシュを生成
    @alc_hash = (start_date..end_date).index_with { |_date| 0 }
    # 飲酒記録が登録されている日付に関しては、摂取アルコール量を代入する
    @record.each do |r|
      if r.drink_day >= Time.zone.today.beginning_of_month && r.drink_day <= Time.zone.today.end_of_month
        alc = ((0.05 * r.beer) + (0.07 * r.highball) + (0.06 * r.chuhi) + (0.15 * r.sake) + (0.12 * r.wine) + (0.43 * r.whiskey) + (0.25 * r.shochu)) * 0.8 # 純アルコール量算出
        @alc_hash[r.drink_day] = alc.round
      end
    end

    # #その他のデータ算出

    # 一回の飲み会あたりの平均アルコール摂取量、飲み過ぎ率、総泥酔回数を算出
    lis_alc = [] # アルコール摂取量を格納する配列
    overdrinking_count = 0 # 飲み過ぎ回数を格納する変数
    @dead_drunk_count = 0 # 泥酔回数を格納する変数

    @record.each do |r|
      # アルコール摂取量を配列lisに格納
      alc = ((0.05 * r.beer) + (0.07 * r.highball) + (0.06 * r.chuhi) + (0.15 * r.sake) + (0.12 * r.wine) + (0.43 * r.whiskey) + (0.25 * r.shochu)) * 0.8
      lis_alc.push(alc)
      # 飲み過ぎ回数をカウント
      overdrinking_count += 1 if r.drunk == 'ふらふらする/呂律が回らない' || r.drunk == '泥酔'
      # 泥酔回数をカウント
      @dead_drunk_count += 1 if r.drunk == '泥酔'
    end

    # 一回の飲み会あたりの平均アルコール摂取量を算出
    @alc_avg = lis_alc == [] ? 0 : lis_alc.sum.fdiv(lis_alc.length).round
    # 飲み過ぎ率を算出
    overdrinking_count.zero? ? @overdrinking_ratio = 0 : @overdrinking_ratio = (overdrinking_count.to_f / @record.length * 100).round
  end
end

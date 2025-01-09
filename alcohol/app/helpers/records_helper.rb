module RecordsHelper
  def calender_days
    def get_calendar_dates(date)
        get_pre_shortage_days(date) + (1..date.end_of_month.day).to_a + get_post_shortage_days(date)
    end

    # その月の、"29 30" 1 のようなカレンダー不足分
    def get_pre_shortage_days(date)
        beginning_day = date.beginning_of_month
        return 0 if beginning_day.wday == 0
        pre_shortage_day = beginning_day - beginning_day.wday.days
        return (pre_shortage_day.day..pre_shortage_day.end_of_month.day).to_a
    end

    def get_post_shortage_days(date)
        end_day = date.end_of_month
        return 0 if end_day.wday == 6
        post_shortage_day = end_day + -(end_day.wday - 6).days
        return (1..post_shortage_day.day).to_a
    end
  end

  def calculate_toughness(record)
    #ウィドマーク法により、アルコール摂取ｔ時間後の血液中アルコール濃度 Ct(mg/ml)は、以下の計算式で得られる。
    # Ct = A/(W×r)ー bt
      # Ct: 血中アルコール濃度(mg/ml)　→以下、conと表記
      # t: アルコール摂取後の経過時間（h） →以下、timeと表記
      # A: 摂取した純アルコール量（g）→以下、alcと表記
      # W: 体重（kg）
      # r: 体内分布係数 
      # b: アルコール減少率　→decと表記
      # W×rを酒の強さと定義し、toughnessとして値を算出する。

    #フォームで送信された飲酒時間、飲酒量を取得
    hours = record.hours.to_f
    minutes = record.minutes.to_f
    beer = record.beer
    highball = record.highball
    chuhi = record.chuhi
    sake = record.sake
    wine = record.wine
    whiskey = record.whiskey
    shochu = record.shochu
    # アルコール量
    alc = (0.05*beer + 0.07*highball + 0.06*chuhi + 0.15*sake + 0.12*wine + 0.43*whiskey + 0.25*shochu)*0.8
    # アルコール減少率（※減少率は個人差があるが、一般的に0.11〜0.19の間に収まり、酒の強さの数値に対し支配的ではないため0.15に固定）
    dec = 0.15
    # 飲み会時間
    time = hours + minutes/60.to_f
    # 血中アルコール濃度
    if record.drunk=="ふらふらする/呂律が回らない"
      con = 2.to_f
    elsif record.drunk=="泥酔"
      con = 3.to_f
    end
    # 酒の強さ計算（ウィドマーク法より）
    @toughness = alc / (con + dec*time)
  end
end

# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # テストユーザーがログイン中の場合にtrueを返す
    def is_logged_in?
      !session[:user_id].nil?
    end

    # テストユーザーとしてログインする
    def log_in_as(user)
      session[:user_id] = user.id
    end

    # 酒の強さを計算
    def calculate_toughness(record)
      # ウィドマーク法により、アルコール摂取ｔ時間後の血液中アルコール濃度 Ct(mg/ml)は、以下の計算式で得られる。
      # Ct = A/(W×r)ー bt
      # Ct: 血中アルコール濃度(mg/ml)　→以下、conと表記
      # t: アルコール摂取後の経過時間（h） →以下、timeと表記
      # A: 摂取した純アルコール量（g）→以下、alcと表記
      # W: 体重（kg）
      # r: 体内分布係数
      # b: アルコール減少率　→decと表記
      # W×rを酒の強さと定義し、toughnessとして値を算出する。

      # フォームで送信された飲酒時間、飲酒量を取得
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
      alc = ((0.05 * beer) + (0.07 * highball) + (0.06 * chuhi) + (0.15 * sake) + (0.12 * wine) + (0.43 * whiskey) + (0.25 * shochu)) * 0.8
      # アルコール減少率（※減少率は個人差があるが、一般的に0.11〜0.19の間に収まり、酒の強さの数値に対し支配的ではないため0.15に固定）
      dec = 0.15
      # 飲み会時間
      time = hours + (minutes / 60.to_f)
      # 血中アルコール濃度
      if record.drunk == 'ふらふらする/呂律が回らない'
        con = 2.to_f
      elsif record.drunk == '泥酔'
        con = 3.to_f
      end
      # 酒の強さ計算（ウィドマーク法より）
      @toughness = alc / (con + (dec * time))
    end
  end

  module ActionDispatch
    class IntegrationTest
      # テストユーザーとしてログインする
      def log_in_as(user, password: 'password', remember_me: '1')
        post login_path, params: { session: { email: user.email,
                                              password:,
                                              remember_me: } }
      end
    end
  end
end

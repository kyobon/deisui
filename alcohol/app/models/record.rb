# frozen_string_literal: true

class Record < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validate :duration_cannot_be_zero
  validates :beer, :highball, :chuhi, :sake, :wine, :whiskey, :shochu, presence: true,
                                                                       numericality: { greater_than_or_equal_to: 0 }
  validate :alcohol_cannot_be_zero

  private

  # 飲み会時間を設定していない場合登録できないようにする
  def duration_cannot_be_zero
    return unless hours.zero? && minutes.zero?

    errors.add(:base, '登録内容に不備があります。')
  end

  # 飲酒量が全て0ccの場合登録できないようにする
  def alcohol_cannot_be_zero
    unless beer.zero? && highball.zero? && chuhi.zero? && sake.zero? && wine.zero? && whiskey.zero? && shochu.zero?
      return
    end

    errors.add(:base, '登録内容に不備があります。')
  end
end

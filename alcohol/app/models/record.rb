class Record < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, { presence: true }
  validate :duration_cannot_be_zero
  validates :beer, :highball, :chuhi, :sake, :wine, :whiskey, :shochu, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :alcohol_cannot_be_zero

  private

  #飲み会時間を設定していない場合登録できないようにする
  def duration_cannot_be_zero
    if hours == 0 && minutes == 0
      errors.add(:base, "登録内容に不備があります。")
    end
  end

  #飲酒量が全て0ccの場合登録できないようにする
  def alcohol_cannot_be_zero
    if beer == 0 && highball == 0 && chuhi == 0 && sake == 0 && wine == 0 && whiskey == 0 && shochu == 0
      errors.add(:base, "登録内容に不備があります。")
    end
  end
end

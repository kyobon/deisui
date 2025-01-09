module LimitsHelper
  def limit_mugs_number(limit_alc)
    require 'bigdecimal'

    #一杯あたりの純アルコール量
    alc_per_beer = 350*0.05*0.8
    alc_per_highball = 350*0.07*0.8
    alc_per_chuhi = 350*0.06*0.8
    alc_per_sake = 45*0.15*0.8
    alc_per_wine = 120*0.12*0.8
    alc_per_whiskey = 30*0.43*0.8
    alc_per_shochu = 90*0.25*0.8

    #アルコールの許容量（杯数へ換算,小数第二位以下切り捨て）
    @beer_mugs = BigDecimal((limit_alc.to_f / alc_per_beer).to_s).floor(1).to_f
    @highball_mugs = BigDecimal((limit_alc.to_f / alc_per_highball).to_s).floor(1).to_f
    @chuhi_mugs = BigDecimal((limit_alc.to_f / alc_per_chuhi).to_s).floor(1).to_f
    @sake_mugs = BigDecimal((limit_alc.to_f / alc_per_sake).to_s).floor(1).to_f
    @wine_mugs = BigDecimal((limit_alc.to_f / alc_per_wine).to_s).floor(1).to_f
    @whiskey_mugs = BigDecimal((limit_alc.to_f / alc_per_whiskey).to_s).floor(1).to_f
    @shochu_mugs = BigDecimal((limit_alc.to_f / alc_per_shochu).to_s).floor(1).to_f

    return {
      beer_mugs: @beer_mugs,
      highball_mugs: @highball_mugs,
      chuhi_mugs: @chuhi_mugs,
      sake_mugs: @sake_mugs,
      wine_mugs: @wine_mugs,
      whiskey_mugs: @whiskey_mugs,
      shochu_mugs: @shochu_mugs
    }
  end
end

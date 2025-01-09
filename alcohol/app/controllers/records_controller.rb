class RecordsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :destroy_record, :edit_by_day, :update_record]

  include RecordsHelper

  def new
    @user = User.find(current_user.id)
    # パラメータでdrink_dayが渡されていたら、その日付のレコードを取得
    if params[:drink_day]
      @record = @user.records.find_by(drink_day: params[:drink_day])
      # もしレコードがなければ新しいレコードを作成
      @record ||= Record.new(drink_day: params[:drink_day])
    else
      @record = Record.new
    end
    @existing_records = @user.records.order(created_at: :desc)
    end

  def create
    @user = User.find(current_user.id)
    @record = Record.new(record_params)
    @record.user_id = current_user.id # Recordモデルにuser_idの値を追加
    if @record.drunk=="ふらふらする/呂律が回らない" || @record.drunk=="泥酔"
      toughness = calculate_toughness(@record) #calculate_toughnessメソッドで酒の強さを算出
      @record.toughness = toughness
    end

    if @record.save
      flash[:success] = "飲酒が記録されました。"
      redirect_to new_record_path, status: :see_other
    else
      flash[:danger] = '登録内容に不備があります。'
      redirect_to new_record_path
    end
  end

  def destroy_record
    drink_day = params[:record][:drink_day]
    @user = User.find(current_user.id)
    @record = @user.records.find_by(drink_day: drink_day)
    if @record.present? # レコードが存在するか確認
      if @record.destroy # レコードの更新
        flash[:success] = "飲酒記録が削除されました。"
        redirect_to new_record_path, status: :see_other
      else
        redirect_to new_records_path, status: :unprocessable_entity
      end
    else
      redirect_to new_record_path
    end
  end

  def edit_by_day
    @no_header_footer = true
    drink_day = params[:drink_day]  # フロントエンドから送信された日付を取得
    @user = User.find(current_user.id)  # 現在のユーザーを取得
    @record = @user.records.find_by(drink_day: drink_day)  # 該当する日付のレコードを取得
  end

  def update_record
    drink_day = params[:record][:drink_day]
    @user = User.find(current_user.id)
    @record = @user.records.find_by(drink_day: drink_day)

    if @record.present? # レコードが存在するか確認
      if @record.update(record_params) # レコードの更新
        drunk = params[:record][:drunk]
        if drunk=="ふらふらする/呂律が回らない" || drunk=="泥酔"
          toughness = calculate_toughness(@record) #calculate_toughnessメソッドで酒の強さを算出
        else
          toughness = nil
        end
        @record.toughness = toughness
        if @record.save
          flash[:success] = "飲酒記録が更新されました。"
          redirect_to new_record_path, status: :see_other
        else
          redirect_to new_record_path, status: :unprocessable_entity
        end
      else
        flash[:danger] = '登録内容に不備があります。'
        redirect_to new_record_path
      end
    else
      redirect_to new_record_path, alert: "指定された飲み会実施日の日付に一致するレコードが存在しません。"
    end
  end

  private

  def record_params
    params.require(:record).permit(:beer, :highball, :chuhi, :sake, :wine, :whiskey, :shochu, :drink_day, :hours, :minutes, :drunk)
  end

end

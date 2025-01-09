class RemoveWeightFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :weight, :integer # ここで :integer の部分は元のカラムの型を記述します
  end
end

class ChangeIdToUuidInUsers < ActiveRecord::Migration[7.1]
  def change
    # idカラムを削除してUUIDに変える
    remove_column :users, :id
    add_column :users, :id, :string, default: -> { "gen_random_uuid()" }, null: false, primary_key: true
  end
end

class AddWeightToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :weight, :integer
  end
end

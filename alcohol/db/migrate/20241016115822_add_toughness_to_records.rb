class AddToughnessToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :toughness, :float
  end
end

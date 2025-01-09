class AddDrunkToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :drunk, :boolean
  end
end

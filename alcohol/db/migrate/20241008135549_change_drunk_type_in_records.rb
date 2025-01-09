class ChangeDrunkTypeInRecords < ActiveRecord::Migration[7.1]
  def change
    change_column :records, :drunk, :string
  end
end

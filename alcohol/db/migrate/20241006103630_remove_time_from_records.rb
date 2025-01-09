class RemoveTimeFromRecords < ActiveRecord::Migration[7.1]
  def change
    remove_column :records, :time, :time
  end
end

class AddHoursAndMinutesToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :hours, :integer
    add_column :records, :minutes, :integer
  end
end

class AddDrinkDayToRecord < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :drink_day, :date
  end
end

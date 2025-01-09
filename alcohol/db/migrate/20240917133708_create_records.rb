class CreateRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :records do |t|
      t.time :time
      t.integer :beer
      t.integer :highball
      t.integer :chuhi
      t.integer :sake
      t.integer :wine
      t.integer :whiskey
      t.integer :shochu
      t.boolean :heavy_drinking
      t.timestamps
    end
  end
end

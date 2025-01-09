class AddUserToRecords < ActiveRecord::Migration[7.1]
  def change
    add_reference :records, :user, null: false, foreign_key: true
    add_index :records, [:user_id, :created_at]
  end
end

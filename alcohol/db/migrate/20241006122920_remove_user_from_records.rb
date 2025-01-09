#class RemoveUserFromRecords < ActiveRecord::Migration[7.1]
#  def change
#    remove_reference :records, :user, null: false, foreign_key: true
#    remove_index :records, [:user_id, :created_at]
#  end
#end

class RemoveUserFromRecords < ActiveRecord::Migration[6.0]
  def change
    if index_exists?(:records, [:user_id, :created_at])
      remove_index :records, [:user_id, :created_at]
    end
    remove_reference :records, :user, null: false, foreign_key: true
  end
end

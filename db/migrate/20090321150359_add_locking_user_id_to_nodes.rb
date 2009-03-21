class AddLockingUserIdToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :locking_user_id, :integer
  end

  def self.down
    remove_column :nodes, :locking_user_id
  end
end

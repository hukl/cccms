class AddHeadIdToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :head_id, :integer
  end

  def self.down
    remove_column :nodes, :head_id
  end
end

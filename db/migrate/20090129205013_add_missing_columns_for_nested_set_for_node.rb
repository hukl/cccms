class AddMissingColumnsForNestedSetForNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :lft, :integer
    add_column :nodes, :rgt, :integer
    add_column :nodes, :parent_id, :integer
  end

  def self.down
    remove_column :nodes, :lft
    remove_column :nodes, :rgt
    remove_column :nodes, :parent_id
  end
end

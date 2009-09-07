class AddTypeColumnToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :type, :string
  end

  def self.down
    remove_column :menu_items, :type
  end
end

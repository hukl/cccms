class AddTypeIdToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :type_id, :integer
  end

  def self.down
    remove_column :menu_items, :type_id
  end
end

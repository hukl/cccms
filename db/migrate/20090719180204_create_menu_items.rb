class CreateMenuItems < ActiveRecord::Migration
  def self.up
    create_table :menu_items do |t|
      t.integer :node_id
      t.string  :path
      t.timestamps
    end
    
    MenuItem.create_translation_table! :title => :string
  end

  def self.down
    drop_table :menu_items
    MenuItem.drop_translation_table!
  end
end

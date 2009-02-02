class AddJoinTableForFlagsPages < ActiveRecord::Migration
  def self.up
    create_table :flags_pages, :id => false do |t|
      t.integer :flag_id
      t.integer :page_id
    end
    add_index :flags_pages, [:flag_id]
    add_index :flags_pages, [:page_id]
  end
  
  def self.down
    remove_table :flags_pages
  end
  
end

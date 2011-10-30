class MigrateTaggingTables < ActiveRecord::Migration
  def self.up
    add_column :tags,     :taggings_count, :integer, :default => 0, :null => false
    add_column :taggings, :user_id, :integer

    add_index :tags,      :name
    add_index :tags,      :taggings_count
    add_index :taggings,  [:user_id, :tag_id, :taggable_type]
    add_index :taggings,  [:user_id, :taggable_id, :taggable_type]
  end

  def self.down
    remove_column :tags,      :taggings_count
    remove_column :taggings,  :user_id
    remove_index  :tags,      :name
    remove_index  :tags,      :taggings_count
    remove_index  :taggings,  [:user_id, :tag_id, :taggable_type]
    remove_index  :taggings,  [:user_id, :taggable_id, :taggable_type]
  end
end

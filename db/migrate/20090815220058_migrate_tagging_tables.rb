class MigrateTaggingTables < ActiveRecord::Migration
  def self.up
    add_column :tags,     :taggings_count, :integer, :default => 0, :null => false
    add_column :taggings, :user_id, :integer
    
    add_index :tags, :name 
    add_index :tags, :taggings_count
    
     Find objects for a tag
    add_index :taggings, [:user_id, :tag_id, :taggable_type]
    
     Find tags for an object 
    add_index :taggings, [:user_id, :taggable_id, :taggable_type]
  end

  def self.down
    remove_column :tags,     :taggings_count
    remove_column :taggings, :user_id
    
    remove_index :tags, :name 
    remove_index :tags, :taggings_count
    
    # Find objects for a tag
    remove_index :taggings, [:user_id, :tag_id, :taggable_type]
    
    # Find tags for an object 
    remove_index :taggings, [:user_id, :taggable_id, :taggable_type]
  end
end

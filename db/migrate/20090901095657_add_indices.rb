class AddIndices < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.index :id
      t.index :node_id
      t.index :user_id
      t.index :revision
    end
    
    change_table :nodes do |t|
      t.index :id
      t.index :slug
      t.index :unique_name
      t.index :lft
      t.index :rgt
      t.index :parent_id
      t.index :head_id
      t.index :draft_id
      t.index :locking_user_id
    end
    
    change_table :page_translations do |t|
      t.index :page_id
      t.index :locale
    end
  end

  def self.down
    change_table :pages do |t|
      t.remove_index :id
      t.remove_index :node_id
      t.remove_index :user_id
      t.remove_index :revision
    end
    
    change_table :nodes do |t|
      t.remove_index :id
      t.remove_index :slug
      t.remove_index :unique_name
      t.remove_index :lft
      t.remove_index :rgt
      t.remove_index :parent_id
      t.remove_index :head_id
      t.remove_index :draft_id
      t.remove_index :locking_user_id
    end
    
    change_table :page_translations do |t|
      t.remove_index :page_id
      t.remove_index :locale
    end
  end
end

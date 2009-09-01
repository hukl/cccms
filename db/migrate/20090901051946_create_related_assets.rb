class CreateRelatedAssets < ActiveRecord::Migration
  def self.up
    create_table :related_assets do |t|
      t.integer :asset_id
      t.integer :page_id
      t.integer :position,  :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :related_assets
  end
end

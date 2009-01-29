class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :slug
      t.string :unique_name

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end

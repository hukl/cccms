class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :node_id
      t.string :title
      t.text :abstract
      t.text :body
      t.integer :revision

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end

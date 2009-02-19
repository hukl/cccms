class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :node_id
      t.integer :revision

      t.timestamps
    end
    
    Page.create_translation_table! :title => :string, :abstract => :text, :body => :text
  end

  def self.down
    drop_table :pages
  end
end

class AddEditorIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :editor_id, :integer
  end

  def self.down
    remove_column :pages, :editor_id
  end
end

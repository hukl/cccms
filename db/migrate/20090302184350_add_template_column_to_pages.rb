class AddTemplateColumnToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :template, :string
  end

  def self.down
    remove_column :pages, :template
  end
end

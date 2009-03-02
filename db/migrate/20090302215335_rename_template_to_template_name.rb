class RenameTemplateToTemplateName < ActiveRecord::Migration
  def self.up
    rename_column :pages, :template, :template_name
  end

  def self.down
    rename_column :pages, :template_name, :template
  end
end

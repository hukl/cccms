class AddStagedSlugAndParentId < ActiveRecord::Migration
  def self.up
    add_column :nodes, :staged_slug,      :string
    add_column :nodes, :staged_parent_id, :integer
  end

  def self.down
    remove_column :nodes, :staged_slug
    remove_column :nodes, :staged_parent_id
  end
end

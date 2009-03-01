class AddDraftIdToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :draft_id, :integer
  end

  def self.down
    remove_column :nodes, :draft_id
  end
end

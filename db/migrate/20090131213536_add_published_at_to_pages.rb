class AddPublishedAtToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :published_at, :datetime
  end

  def self.down
    remove_column :pages, :published_at
  end
end

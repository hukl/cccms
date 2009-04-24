class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string    :name
      t.string    :upload_file_name
      t.string    :upload_content_type
      t.integer   :upload_file_size
      t.datetime  :upload_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end

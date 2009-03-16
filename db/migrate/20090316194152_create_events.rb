class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :rrule
      t.boolean :custom_rrule
      t.boolean :allday
      t.string :url
      t.float :latitude
      t.float :longitude
      t.integer :node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end

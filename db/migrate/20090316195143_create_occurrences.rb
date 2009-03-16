class CreateOccurrences < ActiveRecord::Migration
  def self.up
    create_table :occurrences do |t|
      t.string :summary
      t.datetime :start_time
      t.datetime :end_time
      t.integer :node_id
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :occurrences
  end
end

class RemoveSummaryColumnFromOccurrences < ActiveRecord::Migration
  def self.up
    remove_column :occurrences, :summary
  end

  def self.down
    add_column :occurrences, :summary, :string
  end
end

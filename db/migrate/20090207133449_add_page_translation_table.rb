class AddPageTranslationTable < ActiveRecord::Migration
  def self.up
      Page.create_translation_table! :title => :string, :abstract => :text, :body => :text
    end
    def self.down
      Page.drop_translation_table!
    end
end

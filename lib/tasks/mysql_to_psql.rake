namespace :cccms do

  desc "Import a cccms mysql dump into an external postgres db"

  task :mysql_to_postgres => :environment do

    $connection_options = {
      :adapter => "postgresql",
      :encoding => "unicode",
      :host => "localhost",
      :username => "rails",
      :password => "r3v0lution",
      :database => "cccms_dev"
    }

    class PGUser < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "users"
    end

    class PGNode < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "nodes"
    end

    class PGPage < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "pages"
    end

    class PGPageTranslation < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "page_translations"
    end

    class PGEvent < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "events"
    end

    class PGMenuItem < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "menu_items"
    end

    class PGMenuItemTranslation < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "menu_item_translations"
    end

    class PGOccurrence < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "occurrences"
    end

    class PGTag < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "tags"
    end

    class PGTagging < ActiveRecord::Base
      self.establish_connection($connection_options)
      set_table_name "taggings"
    end

    PGUser.delete_all
    PGNode.delete_all
    PGPage.delete_all
    PGPageTranslation.delete_all
    PGEvent.delete_all
    PGMenuItem.delete_all
    PGMenuItemTranslation.delete_all
    PGOccurrence.delete_all
    PGTag.delete_all
    PGTagging.delete_all

    User.all.each do |user|
      PGUser.create! user.attributes
    end

    Tag.all.each do |tag|
      PGTag.create tag.attributes
    end

    Node.all.each do |node|

      pg_node = PGNode.new node.attributes
      pg_node.locking_user_id = nil
      pg_node.save!
      puts "PGNode #{pg_node.unique_name} created"

      if node.event
        pg_event = PGEvent.new node.event.attributes
        pg_event.node_id = pg_node.id
        pg_event.save
        puts "PGEvent created"
      end

      node.pages.each do |page|
        pg_page = PGPage.create!( page.attributes )
        pg_page.node_id = PGNode.find_by_unique_name(node.unique_name).id
        pg_page.user_id = PGUser.find_by_login(page.user.login).id rescue PGUser.first.id
        pg_page.save
        puts "PGPage created"

        page.tags.each do |tag|
          pg_tagging = PGTagging.create(
            :tag_id         => PGTag.find_by_name(tag.name).id,
            :taggable_id    => pg_page.id,
            :taggable_type  => "Page"
          )
        end

        if node.head && page.id == node.head.id
          pg_node.head_id = pg_page.id
          pg_node.save
          puts "======================Head applied #{pg_page.id}"
        end

        if node.draft && page.id == node.draft.id
          pg_node.draft_id = pg_page.id
          pg_node.save
          puts "Draft applied"
        end

        page.globalize_translations.each do |trans|
          pg_page_trans = PGPageTranslation.new trans.attributes
          pg_page_trans.page_id = pg_page.id
          pg_page_trans.save
          puts "PGPageTranslation created"
        end
      end
    end


    MenuItem.all.each do |item|
      pg_menu_item = PGMenuItem.new item.attributes
      pg_menu_item.node_id = Node.find(item.node_id).id
      pg_menu_item.save
      puts "PGMenuItem created"

      item.globalize_translations.each do |trans|
        pg_menu_item_trans = PGMenuItemTranslation.new trans.attributes
        pg_menu_item_trans.menu_item_id = item.id
        pg_menu_item_trans.save
        puts "PGMenuItemTranslation created"
      end
    end


    puts  "Now recreate Occurrences by running " \
          "Event.all.each {|x| Occurrence.generate(x)} in script/console"

  end

end
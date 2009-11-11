require 'csv'

namespace :cccms do 

  desc "Setup everythin"
  task :setup_environment => [
    :create_admin_user, 
    :import_authors,
    :import_updates, 
    :create_home_page
  ] do |t| 

  end

  desc "Create admin:foobar user:password"
  task :create_admin_user  => :environment do |t| 
    User.create!(
      :login => 'admin', 
      :email => 'admin@cccms.de', 
      :password => 'foobar',
      :password_confirmation => 'foobar',
      :admin => true
    )
  end
  
  desc "Import the authors"
  task :import_authors  => :environment do |t|
    importer = AuthorsImporter.new("#{RAILS_ROOT}/db/authors.csv")
    importer.import_authors
  end  
  
  desc "Update authors on pages"
  task :update_authors_on_pages => :environment do |t|
    i = ChaosImporter.new("#{RAILS_ROOT}/db/updates")
    i.update_authors_on_pages
  end
  
  desc "Import the old XML Files"
  task :import_updates  => :environment do |t|
    i = ChaosImporter.new("#{RAILS_ROOT}/db/updates")
    i.import_updates
  end
  
  desc "Create Home Page"
  task :create_home_page  => :environment do |t|
    n = Node.create :slug => 'home'
    n.move_to_child_of Node.root
    
    d = n.draft
    d.title = "Startseite"
    d.abstract = "Wilkommen auf der Seite des CCC"
    d.body = "Hier gibts content"
    d.save
    
    n.publish_draft!
  end
  
  desc "Convert Entities to real charactes"
  task :convert_entities  => :environment do |t|
    Page.all.each do |page|
      if page.body && page.body != ""
        puts ">> #{page.id} -- #{page.node.unique_name if page.node}"
        tmp_body = page.body.dup
        tmp_body.gsub!(/&auml;/, "ä")
        tmp_body.gsub!(/&ouml;/, "ö")
        tmp_body.gsub!(/&uuml;/, "ü")
        tmp_body.gsub!(/&Auml;/, "ä")
        tmp_body.gsub!(/&Ouml;/, "ö")
        tmp_body.gsub!(/&Uuml;/, "ü")
        tmp_body.gsub!(/&szlig;/, "ß")
        tmp_body.gsub!(/&nbsp;/, " ")
        tmp_body.gsub!(/&ndash;/, "–")
        tmp_body.gsub!(/&micro;/, "µ")
        tmp_body.gsub!(/&sup3;/, "³")
        tmp_body.gsub!(/&eacute;/, "é")
        tmp_body.gsub!(/&sect;/, "§")
        tmp_body.gsub!(/&ldquo;/, "“")
        tmp_body.gsub!(/&rdquo;/, "”")
        tmp_body.gsub!(/&bdquo;/, "„")
        page.body = tmp_body
        page.save
      end
    end
  end
  
  desc "Migrate users to editors"
  task :migrate_editors => :environment do |t|
    Page.record_timestamps = false
    Page.before_save.reject! {|filter| filter.method == :rewrite_links_in_body}
    
    Page.all.each do |page|
      if page.node.locked?
        page.editor = page.node.lock_owner
        puts "#{page.id} #{page.node.lock_owner.login}"
      else
        page.editor = page.user if page.user
      end
      
      page.save!
    end
    
  end
  
  desc "Repair pages without published_at set"
  task :set_published_at => :environment do |t|
    unpublished = Page.all(:conditions => {:published_at => nil})
    unpublished.each do |p|
      p.published_at = p.created_at
      p.save!
    end
  end
  
  desc "Remove pages without a node"
  task :remove_orphans => :environment do |t|
    orphans = Page.all.select { |x| x.node == nil }
    orphans.each { |page| page.destroy }
  end
  
end
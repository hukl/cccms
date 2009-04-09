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
      :password_confirmation => 'foobar'
    )
  end
  
  desc "Import the authors"
  task :import_authors  => :environment do |t|
    importer = AuthorsImporter.new("#{RAILS_ROOT}/db/authors.csv")
    importer.import_authors
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
end
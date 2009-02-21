require 'csv'

namespace :cccms do 

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
    I18n.locale = :en
    @parsed_file = CSV::Reader.parse(File.open("#{RAILS_ROOT}/db/authors.csv"))
    
    @parsed_file.each_with_index do |row, index|
      next if row[0].nil?
      
      unless author = User.find_by_login(row[0])
        puts "#{row[0]} >> #{row[2]}"
        author = User.create!(
          :login => row[0],
          #:realname => row[1],
          :email => row[2],
          :password => "foobartrallala",
          :password_confirmation => "foobartrallala"
        )
      end
      
    end
  end  
  
  desc "Import the old XML Files"
  task :import_updates  => :environment do |t|
    i = UpdateImporter.new("#{RAILS_ROOT}/db/updates")
    i.import_xml
  end
end
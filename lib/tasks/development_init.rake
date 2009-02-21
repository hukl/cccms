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
  
  desc "Import the old XML Files"
  task :import_updates  => :environment do |t|
    i = UpdateImporter.new("#{RAILS_ROOT}/db/updates")
    i.import_xml
  end
end
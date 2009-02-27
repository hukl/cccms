namespace :ci do
  task :fetch_database_config do
    db_config = File.join(%w{config database.sqlite3-sample.yml})
    
    FileUtils.cp db_config, File.join(%w{config database.yml})
  end
end
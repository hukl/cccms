namespace :ci do
  task :fetch_database_config do
    db_config = File.join(%w{config database.sqlite3-sample.yml})
    
    FileUtils.cp db_config, File.join(%w{config database.yml})
  end
  
  task :run_ci do
    
    system "git submodule init"
    system "git submodule update"
    :fetch_database_config
    system "rake db:migrate"
    system "rake db:test:clone"
    system "rake test"
  
  end
end
namespace :ci do
  task :fetch_database_config do
    db_config = File.join(%w{config database.sqlite3-sample.yml})

    FileUtils.cp db_config, File.join(%w{config database.yml})
  end

  desc "run all task necessary to build with integrity"
  task :run_ci do
    if :fetch_database_config && \
       system( "rake db:migrate") && \
       system( "rake db:test:clone") && \
       system( "rake test:coverage")
      puts "succeeded"
    else
      puts "failed"
      exit 1
    end
  end
end
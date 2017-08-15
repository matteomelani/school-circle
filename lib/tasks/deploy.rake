desc 'Deploy on Heroku. Use: rake deploy:heroku app="myapp" target="demo"|"production"|"staging"'
namespace :deploy do
  task :heroku do
    
    app = "#{ENV['app']}"
    if app.blank?
      puts "ERROR: you must specify an app name"
      exit
    end
    
    source_branch = "#{ENV['branch']}"
    if source_branch.blank?
      source_branch = "master"
      puts "WARNING: source branch was not specified using master"
    end
    
    target = "#{ENV['target']}"
    if target.blank?
      puts "ERROR: you must specify a target name"
      exit
    end
    targets=["demo", "staging", "production", "test", "alpha"]
    unless targets.include? target
      puts "ERROR: target '#{target}' is invalid. Accepted value are: #{targets}"
      exit
    end
    resetdb = "#{ENV['resetdb']}"
    if resetdb.blank?
      resetdb = false
    end
    
    env = "#{ENV['target']}"
    
    puts "App settings: "
    puts "   name    = #{ENV['app']}"
    puts "   domain  = #{ENV['target']}"
    
    puts "Deploying on Heroku app: #{app}"
    puts "Determing if application #{app} already exists"
    is_existing_app = true
    sh %{heroku list | grep  "^#{app}$"} do |status, output|
      puts "status = #{status}"
      puts "output = #{output}"
      if ! status
        is_existing_app = false
      end
    end

    puts "is_existing_app = #{is_existing_app}"
    if ! is_existing_app
      puts "Application #{app} needs to be created"
      sh %{ heroku create #{app} --stack cedar }
      sh %{ heroku addons:add custom_domains --app #{app} }
      if app=='alpha'
        puts "Skipping adding cloudmailin addon otherwise you are going to pay twice!"
        #sh %{ heroku addons:add cloudmailin:professional --app #{app} } 
      else
        sh %{ heroku addons:add cloudmailin:developer --app #{app} } 
      end
      # sh %{ heroku addons:upgrade "logging:expanded" --app #{app} }
      sh %{  heroku addons:add "logging:expanded" --app #{app} }
      sh %{ heroku config:add BUNDLE_WITHOUT="development,test" --app #{app} }
      sh %{ heroku config:add RACK_ENV=#{env} --app #{app} }
      sh %{ heroku addons:add pgbackups --app #{app} }
      sh %{ heroku addons:add cron:daily --app #{app} }
      env_to_domain = {
          :production => ["theschoolcircle.com", "www.theschoolcircle.com"],
          :staging    => ["staging.theschoolcircle.com", "www.staging.theschoolcircle.com"],
          :demo       => ["demo.theschoolcircle.com", "www.d.theschoolcircle.com"]
          }
      env_to_domain[target.to_sym].each do |domain|
        sh %{ heroku domains:add #{domain} --app #{app} }
      end  
    end

    sh %{ heroku maintenance:on --app #{app} }
    sh %{ git push git@heroku.com:#{app}.git #{source_branch}:master }
    if ! is_existing_app
      sh %{ heroku run rake db:create --app #{app} }
      sh %{ heroku run rake db:migrate --app #{app} }
      sh %{ heroku run rake db:seed --app #{app} }
    else
      sh %{ heroku run rake db:migrate --app #{app} }  
    end
    sh %{ heroku maintenance:off --app #{app} }
    
    heroku_remote = "heroku-#{app.gsub(/tsc\-/i,'')}"
    puts "Adding #{heroku_remote} to remotes"
     sh %{git remote -v | grep  "#{heroku_remote}"} do |status, output|
        puts "status = #{status}"
        puts "output = #{output}"
        if !status
          sh "git remote add #{heroku_remote} git@heroku.com:#{app}.git"
          sh "git remote -v"
        end
      end
    
    #TODO: run acceptance test against deployed build
  end
end

desc 'Deploy the demo environment on Heroku'
namespace :deploy do
  task :demo do
    ENV['app'] = "tsc-demo" 
    ENV['target'] = "demo"
    Rake.application.invoke_task("deploy:heroku")
  end
end

desc 'Deploy the staging environment on Heroku'
namespace :deploy do
  task :staging do
    ENV['app'] = "tsc-staging" 
    ENV['target'] = "staging"
    Rake.application.invoke_task("deploy:heroku")
  end
end

desc 'Deploy the production environment on Heroku'
namespace :deploy do
  task :production do
    ENV['app'] = "tsc-production" 
    ENV['target'] = "production"
    Rake.application.invoke_task("deploy:heroku")
  end
end

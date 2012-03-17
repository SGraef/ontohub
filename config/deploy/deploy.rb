
namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/"
  end
  
  desc "Moves an replaces secret-token if missing in shared directory"
  task :symlink_secret, :roles => :app, :except => { :no_release => true } do 
    filename       = 'secret_token.rb'
    release_secret = "#{release_path}/config/initializers/#{filename}"
    shared_secret  = "#{shared_path}/config/#{filename}"
    
    if capture("[ -f #{shared_secret} ] || echo missing").start_with?('missing')
      run "mv #{release_secret} #{shared_secret}"
      rake_command "secret:replace"
    end
    
    # symlink secret token
    run "ln -nfs #{shared_secret} #{release_secret}"
  end
end

after "deploy:setup" do
  run "mkdir -p #{shared_path}/config"
  run "mkdir -p #{shared_path}/uploads"
end

after "deploy:cold" do
  puts "an anonymous hook!"
end

after "deploy:update", "deploy:symlink_shared"
after "deploy:update", "deploy:symlink_secret"
after :deploy, "deploy:cleanup"
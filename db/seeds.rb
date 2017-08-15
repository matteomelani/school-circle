puts "\n\n\n"
puts ">>>>>>>>>>>>>  Deleting all data ..."
puts "\n"
ActiveRecord::Base.connection.tables.each do |table|  
  begin
    if table.classify == "Vote"
      klass = "ActsAsVotable::Vote"
    else
      klass=table.classify.constantize
    end
    
    print "\tDeleting all records from #{klass}..."
    klass.delete_all
    print "done!\n"
  rescue NameError
    print "ouch! Table: #{table} cannot be deleted.\n"
  end
end
puts "\n"
puts ">>>>>>>>>>>>>  done "

### Load user data ###
puts "\n\n"
puts ">>>>>>>>>>>>>  Loading Users data ..."
puts "\n"
print "Creating adminteam@theschoolcircle.com ..."

admin = {
      :email      => "adminteam@theschoolcircle.com",
      :username   => "adminteam",
      :password   => "ciaociao",
      :password_confirmation => "ciaociao",
    }

profile = {
          :first_name => "Matteo",
          :last_name => "Melani",
          :sex => "male",
        }
        
u = User.new(admin)
u.build_profile(profile)
u.skip_confirmation! 
u.save!
puts "done."

puts "++++ Loading seed for Rail env \"#{Rails.env}\" ++++"
puts "\n"
case Rails.env
  when "development", "test", "demo"
     load "#{Rails.root}/db/seeds_demo.rb"    
  when "alpha", "production", "staging"
     load "#{Rails.root}/db/seeds_alpha.rb"
  else
     raise "Unknow env #{Rails.env}! Do not know what data to load!"
end
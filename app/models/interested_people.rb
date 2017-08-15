class InterestedPeople < ActiveRecord::Base
  
  validates :email, :format => { :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }

end


# [
#   <InterestedPeople id: 3, email: "mktg@filexindia.com", created_at: "2011-11-08 12:04:00", updated_at: "2011-11-08 12:04:00">, 
#   <InterestedPeople id: 4, email: "natali@sistema.at", created_at: "2011-11-09 15:42:17", updated_at: "2011-11-09 15:42:17">, 
#   <InterestedPeople id: 6, email: "pratikmanu1994@gmail.com", created_at: "2011-12-02 15:14:33", updated_at: "2011-12-02 15:14:33">, 
#   <InterestedPeople id: 7, email: "m.greis@mail.ru", created_at: "2011-12-16 11:05:38", updated_at: "2011-12-16 11:05:38">, 
#   <InterestedPeople id: 8, email: "Maria.simani@ucr.edu", created_at: "2011-12-23 16:00:55", updated_at: "2011-12-23 16:00:55">, 
#   <InterestedPeople id: 9, email: "lombardovito@gmail.com", created_at: "2012-01-04 15:59:27", updated_at: "2012-01-04 15:59:27">, 
#   <InterestedPeople id: 10, email: "kapienv@yahoo.co.in", created_at: "2012-01-20 09:19:21", updated_at: "2012-01-20 09:19:21">, 
#   <InterestedPeople id: 11, email: "corman.camille@gmail.com", created_at: "2012-02-01 23:42:22", updated_at: "2012-02-01 23:42:22">]

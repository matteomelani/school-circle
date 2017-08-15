# sBy using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |u|
  u.sequence(:email)        { |n| "person-#{n}@theschoolcircle.com" }
  u.password                "password"
  u.password_confirmation   { |u| u.password }
  u.profile                 { Factory(:profile) }
  u.after_build             { |u| u.skip_confirmation! }
end

Factory.define :profile do |f|
  f.sequence(:first_name)  { |n| "John" }
  f.sequence(:last_name)   { |n| "Doe" }
  f.birthday             Date.new(1972,04,17)
end

Factory.define :circle do |f|
   f.name                 "Matteo's personal circle"
   f.owner                { Factory(:user) }
   f.source               { |c| c.owner }
   #f.decription           Faker::Lorem.sentences(1)
end

Factory.define :membership do |f|
   f.circle               { Factory(:circle) }
   f.association :user, :factory => :user
end

Factory.define :phone_number do |f|
  f.number                 "(650)462 9497"
  f.owner                  { |pn| pn.association(:owner) }
end

Factory.define :address do |f|
  f.line1                 "812 Woodland Ave." 
  f.city                   "Menlo Park"
  f.state                  "CA"
  f.zipcode                94025
  f.country                "United States"
  f.owner                  { |a| a.association(:owner) }
end

Factory.define :family do |f|
   f.association :user, :factory => :user
   f.name                "Matteo's"
   f.languages           {["English"]}
end

Factory.define :invitation do |f|
  f.inviter                 { Factory(:user) }
  f.sequence(:email)        { |n| "invited-#{n}@theschoolcircle.com" }
  f.circle                  { |a| a.inviter.reload; a.inviter.personal_circle }              
end

Factory.define :school do |f|
  f.sequence(:name)        { |n| "school-#{n}" }
  f.association :user,     :factory=>:user
  f.principal              "John Doe"
  f.grade_range            "k-5"
  f.category               :public
  # f.after_create do |school|
  #      Factory(:address, :owner=>school)
  #   end
  end

Factory.define :classroom do |f|
  f.sequence(:name)       { |n| "classroom-#{n}" }
end

Factory.define :post do |f|
  f.circle                { Factory(:circle) }
  f.sender                { Factory(:user) }
  f.content               "ok"
  f.type                  "Post"
end

Factory.define :message do |f|
  f.circle                { Factory(:circle) }
  f.sender                { Factory(:user) }
  f.content               "ok"
end

Factory.define :comment do |f|
  f.commentable           { Factory(:message) }
  f.user                  { Factory(:user) }
  f.comment               "123"
end


Factory.define :reminder do |f|
  f.circle                { Factory(:circle) }
  f.sender                { Factory(:user) }
  f.content                "This content must be shorter than 140 chars"
end

Factory.define :zfile do |a|
  a.attachable    {Factory(:message)}
end

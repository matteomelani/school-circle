require 'gmail'

Given /^that I am not signed in$/ do
   visit('/users/signout')
end

Given /^I sign out$/ do
   visit('/users/signout')
end

Given /^I do not have an account$/ do
  visit('/users/signout')
  User.delete_all
end

Given /^that I am valid user with the following attributes:$/ do  |users|
  user = users.hashes.first
  And %{I go to the sign up page}
  And %{I fill in "user_profile_attributes_first_name" with "#{user[:first_name]}" within "#new_user"}
  And %{I fill in "user_profile_attributes_last_name" with "#{user[:last_name]}" within "#new_user"}
  # preappending <> to the email is a backdoor to skip email confirmation
  user[:email] = user[:email].delete("<>") 
  And %{I fill in "user_email" with "<>#{user[:email]}" within "#new_user"}
  And %{I fill in "user_password" with "#{user[:password]}" within "#new_user"}
  And %{I press "Ok, I am done" within "#new_user"}
end

Given /^I am a "([^"]*)"$/ do |role|
  steps %Q{
    When I follow "Profile"
    And I select "#{role}" from "profile_main_role"
    And I press "Save"
    }        
end

Given /^I create a new classroom with the following attributes:$/ do |classrooms|
  classroom = classrooms.hashes.first
  steps %Q{
    Given I am on the home page
      And I follow "Create A New Classroom"
      And I fill in "classroom_name" with "#{classroom[:name]}"
      And I fill in "classroom_teacher" with "#{classroom[:teacher]}"
      And I fill in "classroom_grade_level" with "#{classroom[:grade]}"
      And I fill in "classroom_about" with "#{classroom[:about]}"
      And I select "#{classroom[:shool]}" from "classroom_school_id"
    When I press "save"
    Then I should see I18n "controllers.classrooms.create.success"
      And I follow "Home"
  }
end

Given /^that there are the following users:$/ do |users_data|
  @users = users_data
  users_data.hashes.each do |u|
    steps %Q{
      Given that I am valid user with the following attributes:
           | first_name        | last_name        | email        | password      |
           | #{u[:first_name]} | #{u[:last_name]} | #{u[:email]} | #{u[:password]} |
        And that I am not signed in
    }
    
  end
end

Given /^I am sign in with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
   And %{I go to the sign in page}
   And %{I fill in "user_email" with "#{email}" within "#user_new"}
   And %{I fill in "user_password" with "#{password}" within "#user_new"}
   And %{I press "Sign in" within "#user_new"}
end

Given /^that I am signed in with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  Given %{I am sign in with email "#{email}" and password "#{password}"} 
end

#TODO: need to update this step as soon as I have the circle pages up
# these are acceptance tests and need to be runnable against a remote server 
# so local commands do not belongs here.
Given /^that I am user with email "([^"]*)" and my personal circle random name is "([^"]*)"$/ do |user_email, random_name|
  user=User.find_by_email(user_email)
  user.personal_circle.random_name = random_name
  user.personal_circle.save!
end

Given /^I am testing the service$/ do
  c=Circle.find_by_name("John Smith's Personal Circle")
  Message.create(:circle_id=>c.id, :sender_id=>2, :title=>"Hello World", :content=>"Hello There")
end



######################################
#  Sigin in third parties services   #
######################################

Given /^that I have a valid "([^"]*)" account$/ do |arg1|
end

Given /^that I have a valid "([^"]*)" account with email "([^"]*)"$/ do |arg1, arg2|
  #do nothing this is just to clarify what the test does
end

Given /^that I have a valid "([^"]*)" account with email "([^"]*)" and name "([^"]*)"$/ do |provider, email, name|
  OmniAuth.config.test_mode = true
  if provider.downcase == "yahoo" or provider.downcase == "google" or provider.downcase == "aol"   
     # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
     OmniAuth.config.mock_auth[:open_id] = 
     {
         'provider'  => "#{provider}",
         'uid'       => "#{provider}.com",
         'user_info' => { 'email' => "#{email}", 'name' => "#{name}"}
     }
  else
     # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
     OmniAuth.config.mock_auth[:facebook] = {
       'provider' => 'facebook',
       'uid'      => "531564247",
       'credentials' => {
         'token'=> "189157821119422|2.NKt21XnznTNEDPGYXI2UUw__.3600.1300309200-531564247|Mi0DhWREl6g-T9bMZnL82u7s4MI"
         },
       'user_info' => { 
         'nickname'   => "profile.php?id=531564247",
         'email'      => "#{email}",
         'first_name' => "Matteo",
         'last_name'  => "Melani",
         'name'       => "Matteo Melani",
         'image'      => "http://graph.facebook.com/531564247/picture?type=square",
         'urls'       => {
           'facebook' => "http://www.facebook.com/profile.php?id=531564247", 
           'website'  => ""
           }
       },
       'extra' => { 
         'user_hash' => { 
             'id'         => "531564247",
             'name'       => "#{name}",
             'first_name' => "#{name.split(' ')[0]}",
             'last_name'  => "#{name.split(' ')[1]}",
             'link'       => "http://www.facebook.com/profile.php?id=531564247",
             'birthday'   => "04/17/1972",
             'hometown'   => { 
               'id'   => "104048449631599",
               'name' => "Menlo Park, California"
             },
             'location' => { 
               'id'   => "104048449631599",
               'name' => "Menlo Park, California"
             },
             'gender'   => "male",
             'email'    => "#{email}",
             'timezone' => "-7",
             'locale'   => "en_US",
             'verified' => true
           }
         }
       }
  end
end



########### WHEN ##############

When /^I sing out$/ do
  visit('/users/signout')
end


When /^I follow image link "([^"]*)"$/ do |img_alt|
    find(:xpath, "//img[@alt = '#{img_alt}']/parent::a").click()
end

When /^I sign in with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  Given %{I am sign in with email "#{email}" and password "#{password}"}
end


# This step is used since capybara cannot click button on the browser confirm/alert dialog 
# http://stackoverflow.com/questions/2458632/how-to-test-a-confirm-dialog-with-cucumber.
When /^I push the Cancel forever button$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
  page.click_link('Cancel my account forever')
end

When /^I confirm my account with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  gmail = Gmail.connect!("#{email}", "#{password}")
  emails = gmail.inbox.emails(:unread, :after=>1.minutes.ago, :from => "adminteam@theschoolcircle.com", 
              :subject=>"The School Circle - New account confirmation instructions")
  emails.count.should == 1
  conf_email = emails[0]
  body_as_html = Nokogiri::HTML.open(conf_email.body.to_s)
  body_as_html.css('a').count.should == 1
  destination = body_as_html.css('a').attr('href').value
  conf_email.delete
  gmail.logout
  visit(destination)
end

When /^I follow the confirmation link in the email$/ do
  email = last_email
  # http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Element
  simple_node = Capybara.string(email.body.to_s).find_link("Confirm my account")
  visit(simple_node[:href])
end



########### THEN ##############
Then /^I debug$/ do
   debugger
   0
end

Then /^the user count should be (\d+)$/ do |arg1|
  User.count.should == arg1.to_i
end

# This is the i18n version of the step in web_step.rb
Then /^(?:|I )should see I18n "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(I18n.t(text))
    else
      assert page.has_content?(I18n.t(text))
    end
  end
end

# This is the i18n version of the step in web_step.rb
Then /^(?:|I )should not see I18n "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(I18n.t(text))
    else
      assert page.has_no_content?(I18n.t(text))
    end
  end
end

Then /^the system should send an email with the following attributes:$/ do |expected_emails|
  expected_email = expected_emails.hashes.first
  email = last_email
  email.from.should include(expected_email[:from])
  email.to.should include(expected_email[:to])
  email.subject.should == expected_email[:subject]
end
Feature: Sign up with email and password
  In order to access the site
  As a user
  I want to sign up

  Scenario: Sign up with form
    Given I do not have an account
      And I go to the sign up page
      And I fill in "user_profile_attributes_first_name" with "John" within ".signup"
      And I fill in "user_profile_attributes_last_name" with "Smith" within ".signup"
      And I fill in "user_email" with "@gmail.com" within ".signup"
      And I fill in "user_password" with "ciaociao" within ".signup"
    When I press "Ok, I am done!" within ".signup"
     Then I should see "John,"
     And I should see "Thank you for signing up!" 
     And I should see "We have sent you an email at @gmail.com. Follow the included link to confirm your email address."
     And I should see "Didn't receive confirmation instructions?"
     And I should be on the sign up page
     And the user count should be 1
     And the system should send an email with the following attributes:
        | to                     | from                          | subject                                                   |
        | @gmail.com | adminteam@theschoolcircle.com | The School Circle - New account confirmation instructions |
     When I follow the confirmation link in the email
       And I should see "John Welcome to The School Circle."
           
  Scenario: Sign up with form but invalid email
    Given I do not have an account
      And I go to "the sign up page"
      And I fill in "user_email" with "matteo####@gmail.com" within ".new_user"
      And I fill in "user_password" with "ciaociao" within ".new_user"
    When I press "Ok, I am done!"
    Then I should be on the sign up page
      And I should see "is invalid" within ".message[for='user_email']"
      And the user count should be 0
   
  Scenario: Sign up with form but invalid password
    Given I do not have an account
      And I go to "the sign up page"
      And I fill in "user_email" with "matteomleani@gmail.com" within ".new_user"
      And I fill in "user_password" with "ciao" within ".new_user"
    When I press "Ok, I am done!"
    Then I should be on the sign up page
      And I should see "is too short (minimum is 6 characters)" within ".message[for='user_password']"
      And the user count should be 0
  
  Scenario: Sign up with form but invalid first name
    Given I do not have an account
      And I go to "the sign up page"
      And I fill in "user_profile_attributes_first_name" with "#$" within "#new_user"
      And I fill in "user_profile_attributes_last_name" with "Smith" within "#new_user"
      And I fill in "user_email" with "@gmail.com" within "#new_user"
      And I fill in "user_password" with "ciaociao" within "#new_user"
    When I press "Ok, I am done!"
    Then I should be on the sign up page
      And I should see "invalid name format. A name can only contains letters." within ".message[for='user_profile_attributes_first_name']"
      And the user count should be 0
  
  Scenario: Sign up with form but invalid last name
    Given I do not have an account
      And I go to "the sign up page"
      And I fill in "user_profile_attributes_first_name" with "John" within "#new_user"
      And I fill in "user_profile_attributes_last_name" with "#4" within "#new_user"
      And I fill in "user_email" with "@gmail.com" within "#new_user"
      And I fill in "user_password" with "ciaociao" within "#new_user"
    When I press "Ok, I am done!"
    Then I should be on the sign up page
      And I should see "invalid name format. A name can only contains letters." within ".message[for='user_profile_attributes_last_name']"
      And the user count should be 0  
Feature: Smoke Sign up
  In order to access the site
  As a user
  I want to sign up

  @smoke
  Scenario: Sign up with form
    Given I go to the sign up page
      And I fill in "user_profile_attributes_first_name" with "John" within "#new_user"
      And I fill in "user_profile_attributes_last_name" with "Smith" within "#new_user"
      And I fill in "user_email" with "tsc01test@gmail.com" within "#new_user"
      And I fill in "user_password" with "ciaociao" within "#new_user"
    When I press "sign up" within "#new_user"
    Then I should see "John,"
      And I should see "Thank you for signing up!" 
      And I should see "We need to confirm your email address. We have sent you an message at tsc01test@gmail.com, open it and follow the included link."
      And I should see "Didn't receive confirmation instructions?"
    When I confirm my account with email "tsc01test@gmail.com" and password "pizzaMan2011"
    Then I should be on my home page 
     And I should see "John Smith"
     
     
      
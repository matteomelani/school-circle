Feature: Welcome Page
  As I User 
  When I sign in for the first time 
  I want to see a welcome page that offers me a bunch of things to do next
  
  Background: 
    Given that I am valid user with the following attributes:
           | first_name | last_name | email                     | password |
           | John       | Smith     | admin@theschoolcircle.com | ciaociao |
      And that I am not signed in
      And I go to the sign in page
      And I fill in "user_email" with "admin@theschoolcircle.com" within "#user_new"
      And I fill in "user_password" with "ciaociao" within "#user_new"
    When I press "sign in" within "#user_new"
    
  Scenario: Welcome Page and Welcome Page button
    Then I should see "Welcome to The School Circle"
      And I should see "Welcome" within ".super_action"
  
  Scenario: At the 4th sign in user is not shown the welcome page anymore
    And I sign out
    And I sign in with email "admin@theschoolcircle.com" and password "ciaociao"
    And I sign out
    And I sign in with email "admin@theschoolcircle.com" and password "ciaociao"
    And I sing out
    And I sign in with email "admin@theschoolcircle.com" and password "ciaociao"
    Then I should not see "Welcome to The School Circle"
      And I should see "Welcome" within ".super_action"    
Feature: User's Account
  In order to keep using my account with the school circle
  As user
  I want to be able to update my account information

  Background:
    Given that I am valid user with the following attributes:
          | first_name | last_name | email                     | password |
          | John       | Smith     | admin@theschoolcircle.com | ciaociao |
      And I follow "Account"     

  Scenario: Ability to change the username
     When I fill in "user_username" with "newusername"
       And I press "Update"
     Then I should be on admin@theschoolcircle.com's account page   
       And the "user_username" field should contain "newusername"
  
  Scenario: Ability to change the email
    When I fill in "user_email" with "gino123@gmail.com"
      And I press "Update"
    Then I should be on gino123@gmail.com's account page   
      And the "user_email" field should contain "gino123@gmail.com"
  
  Scenario: Ability to change password
    When I fill in "user_password" with "newpassword"
      And I fill in "user_password_confirmation" with "newpassword"
      And I fill in "user_current_password" with "ciaociao"
      And I press "Update"
      And I follow "Sign out"
      And I sign in with email "admin@theschoolcircle.com" and password "newpassword"
    Then I should be on admin@theschoolcircle.com's home page
      And I should see "John Smith"
  
  
  # Need javascript to confirm that I want to delete the account.
  # http://stackoverflow.com/questions/2458632/how-to-test-a-confirm-dialog-with-cucumber
  @javascript @selenium
  Scenario: Delete account
    When I push the Cancel forever button
    Then I should be on the home page
      And I should see "Your account was successfully deleted."
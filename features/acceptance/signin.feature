Feature: Signin
  In order to use the site
  As a User
  I want to sign in

  Scenario: sign in with my email and password
      Given that I am valid user with the following attributes:
             | first_name | last_name | email                     | password |
             | John       | Smith     | admin@theschoolcircle.com | ciaociao |
      And that I am not signed in
      And I go to the sign in page
      And I fill in "user_email" with "admin@theschoolcircle.com" within ".signin"
      And I fill in "user_password" with "ciaociao" within ".signin"
    When I press "Sign in" within ".signin"
    Then I should be on admin@theschoolcircle.com's home page
      And I should see "Signed in successfully."
     
  Scenario: signin with right email but wrong password
      Given that I am valid user with the following attributes:
             | first_name | last_name | email                     | password |
             | John       | Smith     | admin@theschoolcircle.com | ciaociao |
      And that I am not signed in
      And I go to the sign in page
      And I fill in "user_email" with "admin@theschoolcircle.com" within ".signin"
      And I fill in "user_password" with "invalid_password" within ".signin"
    When I press "Sign in" within ".signin"
    Then I should be on the sign in page
      And I should see "Invalid email or password."
  
  Scenario: sign out
      Given that I am valid user with the following attributes:
             | first_name | last_name | email                     | password |
             | John       | Smith     | admin@theschoolcircle.com | ciaociao |
    When I follow "Sign out"
    Then I should be on the home page
      And I should see I18n "devise.sessions.signed_out"
    When I go to admin@theschoolcircle.com's home page
    Then I should see I18n "devise.failure.unauthenticated"  
   
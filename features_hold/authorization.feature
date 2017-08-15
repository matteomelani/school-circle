Feature: Authorization
  In order to trust the School Circle
  As a User
  I want my pages and data to be protected form other users and guests

  Background: There are multiple users
    Given that there are the following users:
      | first_name      | last_name  | email           | password   | 
      | John            | Smith      | user1@mail.com  | mypassword |
      | John            | Smith      | user2@mail.com  | mypassword |
      | John            | Smith      | user3@mail.com  | mypassword |
      | John            | Smith      | user4@mail.com  | mypassword |
      | John            | Smith      | user5@mail.com  | mypassword |

  Scenario: a guest cannot access any user home page
    Given that I am not signed in
    When I go to user1@mail.com's home page
    Then I should be on the sign in page
      And I should see "You need to sign in or sign up before continuing."

  Scenario: a user cannot access other user home page
    Given that I am valid user with the following attributes:
           | first_name | last_name | email                     | password |
           | John       | Smith     | admin@theschoolcircle.com | ciaociao |
    When I go to user2@mail.com's home page
    Then I should be on admin@theschoolcircle.com's home page
      And I should see "You are not authorized to access the page you have requested."

   

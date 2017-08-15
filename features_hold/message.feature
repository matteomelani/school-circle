Feature: post and view messages
  As a User
  In order to communicate with other user
  I want to post messages to circles and view them.

  Background:
    Given that I am valid user with the following attributes:
     | first_name | last_name | email                           | password |
     | John       | Smith     | <>johnsmith@theschoolcircle.com | ciaociao |
     And I am a "teacher"
     And I am on the home page
  
  @javascript
  Scenario: posting a message
    When I follow "post_message_link" within "#post_message_button"
    Then I should see "new_message"
    When I fill in "to" with ""
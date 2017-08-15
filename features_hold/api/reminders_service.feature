Feature: reminders service 
  As an API client
  I want to get the reminders for a specific user in JSON
  In order to display the reminders to the user

  Background: 
    Given that I am valid user with the following attributes:
          | first_name    | last_name | email                      | password |
          | matteo        | melani    | admin@theschoolcircle.com  | ciaociao |
      And that I am not signed in
      And I authenticate as the user "admin@theschoolcircle.com" with the password "ciaociao"
    
  Scenario: get a bunch of reminders
    When I send a GET request to "/api/v1/reminders.json"
    Then the response status should be "200"
  
  Scenario: only accept JSON format
    When I send a GET request to "/api/v1/reminders"
    Then the response status should be "406"
    When I send a GET request to "/api/v1/reminders.xml"
    Then the response status should be "406"
    
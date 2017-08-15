Feature: tokens service 
  As an API client
  I want to to authenticate a user and get an authentication token
  So that I can make API calls on behalf of the user.
  
  
  Background: 
     Given that I am valid user with the following attributes:
              | first_name    | last_name | email                      | password |
              | matteo        | melani    | admin@theschoolcircle.com  | ciaociao | 
      
  Scenario: email and password are correct 
    When I send a POST request to "/api/v1/tokens.json" with the following params:
      """
        {
          :email=>'admin@theschoolcircle.com',
          :password=>'ciaociao',
        }
      """
      Then the response status should be "200"
  
  Scenario: email and password are missing 
    When I send a POST request to "/api/v1/tokens.json" with the following params:
      """
        {
          :pinco=>12
        }
      """
      Then the response status should be "400"

  Scenario: wrong password
    When I send a POST request to "/api/v1/tokens.json" with the following params:
      """
        {
          :email=>'adminteam@theschoolcircle.com',
          :password=>'ciao',
        }
      """
      Then the response status should be "401"

  Scenario: only works with json format 
    When I send a POST request to "/api/v1/tokens" with the following params:
           """
             {
               :email=>'adminteam@theschoolcircle.com',
               :password=>'ciaociao',
             }
           """
    Then the response status should be "406"
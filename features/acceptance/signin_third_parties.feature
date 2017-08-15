Feature: Signinin with third party service: Google, Aol, Facebook and Yahoo 
  In order to use the site
  As a User
  I want to sign in using my Yahoo, Facebook, Gmail or AOL accounts
 
  Before do
    OmniAuth.config.test_mode = true
  end
  
  After do
    OmniAuth.config.test_mode = false
  end
  
  
  Scenario Outline: Sign with valid names and emails
    Given that I have a valid "<provider>" account with email "<email>" and name "<name>" 
      And I go to the sign out page
      And I go to the sign in page
    When I follow image link "<provider>"
    Then I should see "You signed in using your <provider> account ("
      And I should see "Welcome to The School Circle"
      
    Examples: valid name and email variations
        | provider | email                     | name            |
        | Google   | @gmail.com    | matteo melani   |
        | Yahoo    | matteo_melani@yahoo.com   | ma melani       |
        | Aol      | matteo.melani@aol.com     | matt melani     |
        | Facebook | matteo.melani@aol.com     | matt melani     |
  
  Scenario Outline: sign with invalid names and emails
    Given that I have a valid "<provider>" account with email "<email>" and name "<name>" 
      And that I am not signed in
      And I go to the sign in page
    When I follow image link "<provider>"
    Then I should see "The following errors were encountered while signing in with <provider>'s account of user <email>, please fix them and submit the form."
      And I should be on the sign up page

    Examples: invalid name and email variations
      | provider | email                     | name            |
      | Yahoo    | matteo_melani@yahoo.com   | matteo2 melani   |
      | Google   | matteo.melani@gmail.com   | ma melani2       |
      | Google   | matteo-melani@gmail.com   | ma melani2       |

     
  @omniauth_google_failure_test
  Scenario: Sign in with Google account
    Given that I have a valid "Google" account
      And that I am not signed in
      And I go to the sign in page
    When I follow image link "Google"
    Then I should see "Could not authorize you from Open because"
      And I should be on the sign in page
         
  @omniauth_aol_failure_test
  Scenario: sign in with Aol account
    Given that I have a valid "Aol" account
      And that I am not signed in
      And I go to the sign in page
    When I follow image link "Aol"
    Then I should see "Could not authorize you from Open because"
     And I should be on the sign in page

     
    @omniauth_facebook_google_test
    Scenario: Sign in with Facebook then sign in with Google
      Given that I have a valid "Facebook" account with email "@yahoo.com"
        And that I have a valid "Gmail" account with email "@yahoo.com"
        And that I am not signed in
        And I go to the sign in page 
        And I follow image link "Facebook"
        And I should see "You signed in using your Facebook account ("
        And I should be on @yahoo.com's home page
        And that I am not signed in
        And I go to the sign in page
      When I follow image link "Google"
      Then I should see "You signed in using your Google account ("
        And I should be on @yahoo.com's home page
  
      
        

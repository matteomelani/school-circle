Feature: User Profile
  In oder to manage my information
  As a user 
  I want to edit my profile

  Background:
    Given that I am valid user with the following attributes:
      | first_name | last_name | email                     | password |
      | John       | Smith     | admin@theschoolcircle.com | ciaociao |
      And I follow "Profile"
    
    Scenario: Update first name
      Given I fill in "profile_first_name" with "Matteo" within ".edit_profile"
      When I press "Save"
      Then I should see I18n "controllers.users.profiles.update.success"
      When I follow "Profile"
      Then the "profile_first_name" field within ".edit_profile" should contain "Matteo"
  
    Scenario: Update last name
      Given I fill in "profile_last_name" with "Leani" within ".edit_profile"
      When I press "Save"
      Then I should see I18n "controllers.users.profiles.update.success"
      When I follow "Profile"
      Then the "profile_last_name" field within ".edit_profile" should contain "Leani"
         
    Scenario: Update first name with invalid name
      Given I fill in "profile_first_name" with "Matteo!@"
      Then I should see I18n "activerecord.errors.models.profile.attributes.first_name.invalid"
      When I press "Save"
      Then I should not see I18n "controllers.users.profiles.update.success"
           
    Scenario: Update sex 
      Given I select "male" from "profile_sex" within ".edit_profile"
      When I press "Save"
      Then I should see I18n "controllers.users.profiles.update.success"
      When I follow "Profile"
      And the "profile_sex" field within ".edit_profile" should contain "male"
       
   Scenario: Update role
     Given I select "teacher" from "profile_main_role"
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     When I follow "Profile"
     And the "profile_main_role" field should contain "teacher"
         
   Scenario: Update location
     Given I fill in "profile_location_attributes_input_string" with "Menlo Park"
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     When I follow "Profile"
     And the "profile_location_attributes_input_string" field should contain "^Menlo Park, CA, USA$"
     Given I fill in "profile_location_attributes_input_string" with "94025"
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     And the "profile_location_attributes_input_string" field should contain "^Menlo Park, CA 94025, USA$"
     Given I fill in "profile_location_attributes_input_string" with "812 woodland, Menlo Park"
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     And the "profile_location_attributes_input_string" field should contain "^812 Woodland Ave, Menlo Park, CA 94025, USA$"
     
   Scenario: Update location with invalid location
     Given I fill in "profile_location_attributes_input_string" with "Location that does not exist."
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     And the "profile_location_attributes_input_string" field should contain "^Location that does not exist.$"
       
   Scenario: Update mobile phone number
     Given I fill in "profile_phone_numbers_attributes_0_number" with "(415)2903390"
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
     When I follow "Profile"
      And the "profile_phone_numbers_attributes_0_number" field should contain "^\(415\)2903390$"
           
   Scenario: Update mobile phone number with invalid phone number
     Given I fill in "profile_phone_numbers_attributes_0_number" with "invalid phone number."
     Then I should see I18n "activerecord.errors.models.phone_number.attributes.number.invalid"
     When I press "Save"
     Then I should not see I18n "controllers.users.profiles.update.success"
        
   Scenario: Delete mobile phone number
     Given I fill in "profile_phone_numbers_attributes_0_number" with "(415)2903390"
     Then I press "Save"
     Then I follow "Profile"
      And the "profile_phone_numbers_attributes_0_number" field should contain "^\(415\)2903390$"
     Then I fill in "profile_phone_numbers_attributes_0_number" with ""
     When I press "Save"
     Then I should see I18n "controllers.users.profiles.update.success"
      And the "profile_phone_numbers_attributes_0_number" field should contain ""
   
  Scenario: Update mobile and home phone number
    Given I fill in "profile_phone_numbers_attributes_0_number" with "(415)290-3390"
     And I fill in "profile_phone_numbers_attributes_1_number" with "(650)291-5590"
    When I press "Save"
    Then I should see I18n "controllers.users.profiles.update.success"
    When I follow "Profile"  
    Then the "profile_phone_numbers_attributes_0_number" field should contain "^\(415\)290-3390$"
      And the "profile_phone_numbers_attributes_1_number" field should contain "^\(650\)291-5590$"
    Given I fill in "profile_phone_numbers_attributes_0_number" with ""
    When I press "Save"
    Then I should see I18n "controllers.users.profiles.update.success"
      And the "profile_phone_numbers_attributes_1_number" field should contain ""
      And the "profile_phone_numbers_attributes_0_number" field should contain "\(650\)291-5590"
   
   #TODO: test profile photo upload
   @todo
   Scenario: Upload photo from file
   
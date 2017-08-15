Feature: Classroom  
  As a Teacher
  In order to communicate with the parents
  I want to create and manage a classroom circle

  Background:
    Given that I am valid user with the following attributes:
               | first_name | last_name | email                       | password |
               | John       | Smith     | <>johnsmith@theschoolcircle.com | ciaociao |
      And I am a teacher
      And I am on the home page
    
  Scenario: Classroom setup action
    Then I should see "Create A New Classroom"
      
  Scenario: Create a new classroom
    When I follow "Create A New Classroom"
    Then I should see "Classroom info" within ".user_strip"
      And I should see "Classroom members" within ".user_strip"
    Given I fill in "classroom_name" with "preschool"
      And I fill in "classroom_teacher" with "Mrs. Vegas"
      And I fill in "classroom_grade_level" with "k-12"
      And I fill in "classroom_about" with "This is a nice classroom"
      And I select "Menlo Children's Center" from "classroom_school_id"
    When I press "save"
    Then I should see I18n "controllers.classrooms.create.success"
      And the "classroom_name" field should contain "^preschool$"
      And the "classroom_teacher" field should contain "^Mrs. Vegas$"  
      And the "classroom_grade_level" field should contain "^k-12$"
      And the "classroom_about" field should contain "^This is a nice classroom$"
      And the "classroom_school_id" field should contain "^3$"
      
  Scenario: Edit classroom info
    Given I create a new classroom with the following attributes: 
        | name      | teacher  | school                | grade     | about                                 |
        | preschool | Mrs Lisa | Menlo Children Center | Preschool | This is the best school in menlo park |
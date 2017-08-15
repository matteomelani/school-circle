Feature: Manage Family data 
     In order to get news from my kids school 
     As a parent
     I want to set up my family circle

  
   Background:
     Given that I am valid user with the following attributes:
              | first_name | last_name | email                       | password |
              | John       | Smith     | johnsmith@theschoolcircle.com | ciaociao |
     And I am a "parent"
     And I go to the home page   
     
  Scenario: setup family action
    Then show me the page
    Then I should see "Setup My Family" within "#super_actions"
    When I follow "Setup My Family" within "#super_actions"
    Then I should be on the new family page
      And I should see "My Profile" within ".user_strip_links"
      And I should see "My Family" within ".user_strip_links"
      And I should see "First enter some basic info about your family, then add adults and children info."
      
  Scenario: create family
    
    
  
  
# User creates a family: 
#   he sets the family name, location and languages
#   When
#   with the adult role and owner role.
#   A user can only own one family at a time (the case where one user has 2 or more family is not model, the user will 
#   have to choose the a primary family and then it will be invited as and admin to the second family).

    
# User destroy a family:
#   he goes to the settings->family, if he is the family_owner a link "delete family and all its data" will 
#   appear at the bottom of the page. If the user click the link an alert will be displayed saying: "Are you
#   sure?". If the user confirms then the family object and circle will be destroyed and the user will be 
#   redirected to his home page.


# User adds an adult member to the family:
#  He sends an invitation to the adults members, he enters the adult email, first and last name.
#  and a role that the adult will have. The adult can have the following roles:
#     - family_owner: can CRUD a family object and its memberships
#     - family_admin: same as family_owner but cannot delete a family
#     - family_reader: can only read the family data
#      
#  If the user is already a member of the school circle a confirmation email is sent to the 
#  adult member that can accept or refuse.
#  If the user is not a member of the school circle and invitation email is sent to him. The 
#  invitation email contains a link when the adult clicks on the link he is taken to the 
#  sign up page. After he sign ups what ever information was in the invitation is applied to 
#  the new user profile and circle membership.
#
#
# User can remove himself from a family: 
# If there are more than one adult admin in the family then a user can remove himself from the family.
# If he is the only admin he cannot remove himself

# Implementation
# A user can be a member of many Family circles
# A user can be the family_owner of only one family circle
# Each family circle has only one family_owner
# The family_owner invites other adults to the family circle, at invitation times the owner decides
# the role of the adults, either family_admin, family_parent or family_reader. A family_parent will
# have its family page set to the family its invited too. family_admin can pretty much do whatever 
# a family_parent can do but his family page will not be set to the family. family_reader will only
# have read rights to the family data.
#

# Adding/Removing children
#  when a children is assigned to a classroom/school then the parent is also a member of the same 
# circles. In other words parent and children memberships must be kept in sync (only from the child 
# side). Note that if a parent has 2 kids in the same classroom/school and one of the child is 
# removed from the classroom the parent need to maintain the membership to the classroom because 
# of the other child
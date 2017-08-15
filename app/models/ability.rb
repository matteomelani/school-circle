class Ability
  include CanCan::Ability

  def initialize(user)
    # user is set to current_user

    # Users
    can [:show, :post_board, :welcome], User, :id => user.id
    can [:update, :destroy], User do |u|
      #can only update children data if user is a family admin
      if user.my_family and user.has_role?(Circle::ADMIN_ROLE, user.my_family.circle) and user.my_family.children.include?(u)
        true
      end
    end
    can [:create], User do |u|
       user.my_family
    end
    
    # Accounts
    # The high level object account is implemented by a Registration which is 
    # not a Model. Please see the RegistrationsController class.
    #can [:new, :create, :show, :update, :edit, :destroy], User, :id => user.id
    
    # Profiles
    can [:show, :update, :edit], Profile, :user_id => user.id
    can [:new, :create, :show, :update, :edit, :destroy], PhoneNumber do |p|
      if (p.owner_type == "profile")
        :owner_id.to_i == user.profile.id
      else
        false
      end
    end
    
    # Authentications
    can [:new, :create, :show, :update, :edit, :destroy], Authentication, :user_id => user.id
    
    # Invitations
    can [:show, :update, :edit, :destroy], Invitation, :inviter_id => user.id
    can [:create], Invitation do |invitation|
       if (invitation.inviter==user && (user.memberships.select { |m| m.circle_id == invitation.circle_id }.count>0))
         true
       end
    end
    can [:accept], Invitation do |invitation|
      invitation.email == user.email
    end
    
    # Circles
    can [:index, :show, :edit, :update, :destroy], Circle do |circle|
      user.has_role?(Circle::ADMIN_ROLE, circle)
    end
    can [:index, :show, :invite], Circle do |circle|
      user.has_role?(Circle::USER_ROLE, circle)
    end
    
    # Families
    can [:show, :edit, :update, :destroy], Family do |family|
      user.has_role?(Circle::ADMIN_ROLE, family.circle)
    end
    can [:index, :show], Family do |family|
      user.has_role?(Circle::USER_ROLE, family.circle)
    end
    
    # Classrooms
    can [:index, :show, :edit, :update, :destroy], Classroom do |classroom|
      user.has_role?(Circle::ADMIN_ROLE,classroom.circle)      
    end
    can [:index, :show], Classroom do |classroom|
      user.has_role?(Circle::USER_ROLE, classroom.circle)
    end
    
    # Groups
    can [:index, :show, :edit, :update, :destroy], Group do |group|
      user.has_role?(Circle::ADMIN_ROLE, group.circle)      
    end
    can [:index, :show], Group do |group|
      user.has_role?(Circle::USER_ROLE, group.circle)      
    end
    
    # School
    can [:index, :show, :edit, :update, :destroy], School do |school|
      user.has_role?(Circle::ADMIN_ROLE,school.circle)      
    end
    can [:index, :show], School do |school|
      user.has_role?(Circle::USER_ROLE, school.circle)      
    end
    
    # Memberships
    can [:index, :show, :edit, :update, :destroy], Membership do |membership|
      user.has_role?(Circle::ADMIN_ROLE, membership.circle)
    end
    can [:index, :show], Membership do |membership|
      user.has_role?(Circle::USER_ROLE, membership.circle)      
    end
    
    # Posts
    can [:show, :create, :edit, :update], Post do |post|
      if post.circle
        user.has_role?(Circle::USER_ROLE, post.circle)
      end
    end
    
    # Reminders
    can [:index], Reminder do |post|
      user.has_role?(Circle::USER_ROLE, post.circle)
    end
    
    # Message
    can [:show, :create, :edit, :update], Message do |message|
      if message.circle
        user.has_role?(Circle::USER_ROLE, message.circle)
      else
        user.neighbours.include? User.find(message.receiver_id)
      end
    end
    
    # Zfile
    can [:create], Zfile do |a|
      false   
    end

    # Comments
    can [:create], Comment do |comment|
      true if comment.commentable.is_a? Post and user.has_role?(Circle::USER_ROLE, comment.commentable.circle)
    end
    can [:destroy], Comment, :user_id => user.id
    
    # Documents
    can [:destroy], Document do |document|  
      user.has_role?(Circle::ADMIN_ROLE, document.circle)
    end
    can [:index, :show], Document do |document|
      user.has_role?(Circle::USER_ROLE, document.circle)
    end
    
      
  end


end

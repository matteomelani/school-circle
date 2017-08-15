class UserMailer < ActionMailer::Base
  
  def family_invitation(invitation)
    @invitation = invitation
    @circle_name = invitation.circle.name
    @registration_url = new_registration_users_url
    if invitation.inviter.email.start_with?("+")
      logger.info("invitation email start with + skipping sending the email.")
    else
      mail(:from    => "#{invitation.inviter.profile_full_name}  <#{invitation.inviter.email}>",
           :to      => "#{invitation.email}",
           :subject => I18n.t('mailers.user_mailer.family_invitation.subject', :inviter_full_name=>invitation.inviter.profile_full_name,:circle_name=>invitation.circle.name))
    end  
  end
  def circle_invitation(invitation)
     @invitation = invitation
     @accept_invitation_url = invitation_accept_url(@invitation, :token=>@invitation.token)
     if not User.find_by_email(@invitation.email)
       @accept_invitation_url = invitation_accept_new_user_url(@invitation, :token=>@invitation.token)
     end
     @registration_url = new_registration_users_url
     if invitation.inviter.email.start_with?("+")
       logger.info("invitation email start with + skipping sending the email.")
     else
       mail(:from    => "#{invitation.inviter.profile_full_name}  <#{invitation.inviter.email}>",
            :to      => "#{invitation.email}",
            :subject => I18n.t('mailers.user_mailer.circle_invitation.subject', :inviter_full_name=>invitation.inviter.profile_full_name, :circle_name=>invitation.circle.name),
            :content_type=>"text/html"
            )
     end  
   end
  
end

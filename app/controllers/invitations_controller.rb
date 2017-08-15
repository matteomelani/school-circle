class InvitationsController < ApplicationController
  
  before_filter :authenticate_user!, :except=>[:accept_new_user]
  load_and_authorize_resource :except=>[:new, :create, :accept_new_user]
  
  # respond_to :json, :js
  def new
    @invitation = Invitation.new(:inviter=>@user)
  end
  
  def create
     # make sure the user is a member of the circle he is inviting to!
     can? :invite, Circle.find(params[:invitation][:circle_id])      
     if params[:invited_persons].count > 0
       # The user wants to invites multiple people, process the invited_people hash and create 
       # on invitation object for each invited person
       @invitations = []
       params[:invited_persons].each do |invited_person| 
         @invitation = Invitation.new(params[:invitation])
         @invitation.email = invited_person['email']  
         @invitation.registration_info[:first_name]=invited_person['first_name'] if invited_person['name'] && invited_person['name'].split(' ')[0]
         @invitation.registration_info[:last_name]=invited_person['last_name'] if invited_person['name'] && invited_person['name'].split(' ')[1]     
         if @invitation.memberships.empty?
            @invitation.registration_info[:memberships]=[{:circle_id=>@invitation.circle.id, :roles=>@invitation.circle.source.default_membership.roles}]
         end
         if @invitation.save
           @invitations << @invitation  
           UserMailer.circle_invitation(@invitation).deliver
           @invitation.sent_on=Time.now
           @invitation.times_sent=@invitation.times_sent+1
           @invitation.save!          
         else
           # found an error! Return the wrong invitation
           respond_with(@invitation)
         end
       end
       # hide the token for security reasons
       render :json=>@invitations.map! {|i| i.token=nil; i;}
     else
       # The user is inviting a single person, the invited_persons array is empty. This
       # is the classic form processing
       @invitation = Invitation.new(params[:invitation])
       if @invitation.save and UserMailer.circle_invitation(@invitation).deliver
       end
       respond_with(@invitation)
     end
   end
  
  # this is to address the case that one user has a session open from a computer, then a second user uses the same computer 
  # to accept an invitation therefore the secodn user get the "You are already sign in" message. I do not know how to
  # customize devise to go around that.
  def accept_new_user
    if current_user
      sign_out current_user
    end
    redirect_to new_registration_users_path(:token=>params[:token])
  end
  
  def accept
    @invitation = Invitation.find_by_token_and_is_used(params[:token], false)
    if ! @invitation
      flash[:error]=I18n.t 'controllers.invitations.accept.error.invitation_not_found'
    elsif Time.now > @invitation.expires_on
      flash[:error]=I18n.t 'controllers.invitations.accept.error.invitation_expired'
    elsif @invitation.email != @user.email
      flash[:error]=I18n.t 'controllers.invitations.accept.error.invitation_and_user_different_emails'
      sign_out @user
    elsif ! @invitation.accept
      flash[:error]=I18n.t 'controllers.invitations.accept.error.user_is_already_member'
    else
      flash[:success]=I18n.t 'controllers.invitations.accept.success', :inviter=>@invitation.inviter.profile_full_name, :circle=>@invitation.circle.source.display_name
    end
    redirect_to root_path  
  end
  
end

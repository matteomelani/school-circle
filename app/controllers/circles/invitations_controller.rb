#TODO: DRY, this controller needs to go and just use the other invitation controller

class Circles::InvitationsController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource :circle
  load_and_authorize_resource :invitation, :through=>:circle, :except=>[:new]
  
  respond_to :json, :js
  
  def new
    @invitation=Invitation.new(:inviter=>@user, :circle_id=>params[:circle_id])
    source = @invitation.circle.source
    def_m = source.default_membership
    @invitation.registration_info={ :memberships=>[{:circle_id=>params[:circle_id], :roles=>def_m.roles} ] }     
  end
  
  def create
    # change the memberships from a string into an array
    refine(params[:invitation])
    
    if params[:invited_persons].count > 0
      # The user wants to invites multiple people, process the invited_people hash and create 
      # on invitation object for each invited person
      @invitations = []
      params[:invited_persons].each do |invited_person| 
        @invitation = Invitation.new(params[:invitation])
        @invitation.email = invited_person['email']  
        @invitation.registration_info[:first_name]=invited_person['first_name'] if invited_person['name'].split(' ')[0]
        @invitation.registration_info[:last_name]=invited_person['last_name'] if invited_person['name'].split(' ')[1]     
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
   
  def destroy
    @invitation.destroy
    logger.info("Invitation successfully destroied returning: #{@invitation}")
    respond_with(@invitation)  
  end
  
  
  private
  # Change the memberships from a string to an array. This s done here so that the form code is  
  # simple the problem is that we now have a security hole.
  # TODO: change the form so that the membership is a hash like this:
  #   { :circle_id=>12, :roles=>[ "admin", "family_boss"] }
  # (is this possible?)
  def refine(invitation)
    a={}
    if (invitation['registration_info']['memberships'])
      a=a.merge(invitation)
      a['registration_info']['memberships']=eval(invitation['registration_info']['memberships'])    
      a
    else
      invitation
    end
  end

end

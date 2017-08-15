
## This controller is only use to display the html version of the emails 
## the system send out in order to aid development.
if Rails.env == "development"
  class EmailsController < ApplicationController
    before_filter :authenticate_user!
 
    def index
    end
  
    def invitation
      @invitation = Invitation.new(:inviter=>current_user, :circle=>Classroom.find(17).circle)
      render 'user_mailer/circle_invitation'
    end
  
  end
  
end
class Api::V1::RemindersController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :user
  load_and_authorize_resource :reminder, :through => :user
   
  respond_to :json
  
  #TODO: need to create a APIApplicationController< ApplicationController
  def index
    if request.format != :json
       render :status=>406, :json=>{}
       return
    end
    
    @reminders = @user.reminders.includes(:circle, :sender=>[:profile]).paginate(:page=>params[:page], :per_page=>(params[:per_page]||10))
    @new_reminders = @reminders.collect { |r| {:to=>r.circle.name, :from=>r.sender.profile_full_name, :sender_image_url=>r.sender.profile.avatar_url, :content=>r.content, :posted_at=>r.created_at} }
    respond_with(@new_reminders)  
  end
  
end
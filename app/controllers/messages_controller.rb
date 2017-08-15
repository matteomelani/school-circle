class MessagesController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:new, :create, :index]
  respond_to :js
  
  def index 
    if params[:circles]
      circles = params[:circles].collect {|c| c.to_i}.compact
    else
      circles = @user.circles.collect{|c| c.id}
    end
    
    if params[:thread_id]
      @messages = Message.where("(circle_id IN (:circles_filters) OR (receiver_id=:receiver_id)) AND thread_id=:thread_id", :circles_filters=>circles, :receiver_id=>@user.id, :thread_id=>params[:thread_id])
                         .paginate(:page=>params[:page], :per_page=>params[:per_page] || 100)
    else  
      @messages = Message.where("circle_id IN (:circles_filters) OR (receiver_id=:receiver_id)", :circles_filters=>circles, :receiver_id=>@user.id)
                         .paginate(:page=>params[:page], :per_page=>params[:per_page] || 100)
    end
    respond_with(@messages)
  end
  
  def new
    @message = nil
    # is this is a reply?
    if params[:parent_id] and params[:reply_to]
      @parent_message = Message.find(params[:parent_id])
      if @parent_message and can_reply?(current_user, @parent_message)
        # you can only reply to this message if the parent message was directed to you or you are a member of a circle the message is posted to.
        @message = @parent_message.new_reply(params[:reply_to], current_user)        
      else
        # ok just create a regular new message      
        @message = Message.new(:sender=>current_user)
      end
    else
      # ok just create a regular new message
      @message = Message.new(:sender=>current_user)
    end
  end

  def create
    @message=Message.new(params[:message])
    authorize! :create, @message
    @message.sender = @user
    @message.zfile_ids = params[:zfile_ids]
    if @message.save
      # Why am I calling this? Does it have to do with uploadify? 
      current_user.ensure_authentication_token
      flash.now[:success] = I18n.t "controllers.messages.create.success"
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
  end
  
  
  private
  
  def can_reply?(user, message)
    !(message.receiver_id != user.id and Membership.where(:circle_id=>message.circle.id, :user_id=>user.id).empty?)
  end
  
end

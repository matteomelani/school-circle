class Messages::CommentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :user
  load_and_authorize_resource :message
  load_and_authorize_resource :comment, :through=>:message

  respond_to :js, :json

  def index
    @comments = @message.comments
  end

  def create
    if @comment.save
      render :template=>'messages/comments/create'
    else
      logger.error("Cannot save comment: #{@comment.errors}")
      flash[:error]=I18n.t "controllers.messages.comments.create.error", :errors=>@comment.errors
      render :template=>'messages/comments/create_error', :status=> 400
    end
  end

  def destroy
    @comment.destroy
    respond_with(@comment)
  end

end
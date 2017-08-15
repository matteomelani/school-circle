require 'will_paginate/array'

class UsersController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :json, :html, :js
  
  def show
    if @user.sign_in_count == 1
      flash[:notice] = I18n.t 'controllers.users.show.first_signin_message', :user_first_name=>@user.profile.first_name
    end
    flash.each do |key, value|
      flash[key] = value
    end
    #TODO: remove this redirect the right way si to use JS
    redirect_to user_post_board_path(@user)
  end

  # the only user that can be create are children :-)
  def create
    @user = User.create_child(params[:user])
    if @user.errors.empty?
      Zfile.set_attachable(params[:avatar_id], @user.profile) if params[:avatar_id]
    else
      flash[:error] = I18n.t 'controllers.users.create.error', :user_full_name=>@user.profile_full_name   
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      Zfile.set_attachable(params[:avatar_id], @user.profile) if params[:avatar_id]
      flash.now[:success]=I18n.t 'controllers.users.update.success', :user_full_name=>@user.profile_full_name
    else
      flash.now[:error]=I18n.t 'controllers.users.update.error', :user_full_name=>@user.profile_full_name, :errors=>@user.errors 
    end
    respond_with(@user)
  end
  
  def destroy
    @user.destroy
    respond_with(@user)
  end
  
  # NOTE: See ApplicationController.set_user comment.
  # DO NOT REMOVE THIS METHOD!
  def set_user
    if params[:id]
      @user = User.find(params[:id])
    else
      @user=current_user
    end
  end

  def post_board
    circles = []
    
    #NOTE: code is not DRY for clarity.
    
    if params[:children]
      child = @user.children.find { |c| c.profile_first_name.downcase==params[:children].downcase}
      if child
        circles = circles | child.circles  #get the union
        @feed_items = Post.filter_by_circles_collapse_threads_and_paginate(circles, params[:page] || 1, params[:per_page] || 10)  
      else
        @feed_items = [].paginate(:page=>1, :per_page=>10)
      end
      render 'post_board'
      return
    end
    
    if params[:circles]
      circles = params[:circles].collect {|c| c.to_i}.compact
      if circles.nil? or circles.empty?
        @feed_items = [].paginate(:page=>1, :per_page=>10)
      else
        @feed_items = Post.filter_by_circles_collapse_threads_and_paginate(circles, params[:page] || 1, params[:per_page] || 10) 
      end
      render 'post_board'
      return
    end
    
    # no filter so returns all the posts directed to the user and to his circles
    @feed_items = Post.all_for_user_collapse_threads_and_paginate(@user, params[:page] || 1, params[:per_page] || 10) 
  end
  
  def welcome
  end
        
end
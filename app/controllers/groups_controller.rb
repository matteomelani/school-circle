class GroupsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except=>[:index, :new,   :create]
  respond_to :html, :json, :js
  def index
    @groups = Group.paginate(:page=>params[:page])
  end
  
  def new
    @group=Group.new
  end
  
  def create
    @group = Group.new(params[:group])
    @group.user=@user
    if @group.save
      Zfile.set_attachable(params[:avatar_id], @group) if params[:avatar_id]
      flash[:success]=I18n.t 'controllers.groups.create.success', :circle=>@group.name
      redirect_to @group
    else
      flash.now[:error]=I18n.t 'controllers.groups.create.error', :circle=>@group.name, :errors=>@group.errors
      redner 'new'
    end
  end
  
  def show
    @feed_items = @group.circle.feed_items(params[:page] || 1, params[:per_page] || 10)
  end
  
  def edit
  end
  
  def update
    if @group.update_attributes(params[:group])
      Zfile.set_attachable(params[:avatar_id], @group) if params[:avatar_id]
      flash[:success] = I18n.t 'controllers.groups.update.success', :circle=>@group.name
      redirect_to edit_group_path(@group)
    else
      flash[:error] = I18n.t 'controllers.groups.update.error', :circle=>@group.name
      render 'edit'
    end
  end
  
  def destroy
    @group.destroy
    flash.now[:success]=I18n.t 'controllers.groups.destroy.success', :circle=>@group.display_name
    respond_with(@group)
  end
        
end
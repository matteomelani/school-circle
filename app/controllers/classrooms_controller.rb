class ClassroomsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :except=>[:new, :create, :index]
  respond_to :html, :json, :js
  
  def index
  end
  
  def new
    @classroom = Classroom.new(:user=>@user)
  end
  
  def create
    @classroom = Classroom.new(params[:classroom])
    @classroom.user=@user
    if @classroom.save
      Zfile.set_attachable(params[:avatar_id], @classroom) if params[:avatar_id]
      flash.now[:success]=I18n.t 'controllers.classrooms.create.success', :classroom=>@classroom.display_name
    else
      flash.now[:error]=I18n.t 'controllers.classrooms.create.error', :classroom=>@classroom.display_name, :errors=>@classroom.errors
    end
    @classroom.reload
    respond_with(@classroom)
  end

  def show
    @feed_items = @classroom.circle.feed_items(params[:page] || 1, params[:per_page] || 10)
  end

  def edit
    @classroom = Classroom.find(params[:id])
    @memberships = @classroom.circle.memberships
  end

  def update
    @classroom = Classroom.find(params[:id])    
    Zfile.set_attachable(params[:avatar_id], @classroom) if params[:avatar_id]
    if @classroom.update_attributes(params[:classroom])
      flash.now[:success]=I18n.t 'controllers.classrooms.update.success', :classroom=>@classroom.display_name
    else
      flash.now[:error]=I18n.t 'controllers.classrooms.update.error', :classroom=>@classroom.display_name
    end
    respond_with(@classroom, :location=>edit_classroom_path(@classroom))
  end

  def destroy
    @classroom.destroy
    flash.now[:success]=I18n.t 'controllers.classrooms.destroy.success', :classroom=>@classroom.display_name
    respond_with(@classroom)
  end

end

class Users::CirclesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  
  BILLBOARD_POST_PER_PAGE = 5
  CIRCLE_PER_PAGE = 5
  
  respond_to :html, :json
  def index
    @circles = @user.circles.paginate(:page => params[:page],:per_page=>CIRCLE_PER_PAGE)
  end

  def new
    @circle = @user.owned_circles.build
  end

  def create
  end

  def edit
   @circle = Circle.find_by_id(params[:id])
   respond_to do |format|
         format.js {render :layout=>false}
   end
  end

  def update
  end

  def destroy
  end

  def show
    @billboard_posts = @circle.billboard_posts.paginate(:page => params[:page],:per_page=>BILLBOARD_POST_PER_PAGE)
  end


end

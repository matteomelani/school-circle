class CirclesController < ApplicationController

  before_filter :authenticate_user!, :except=>[:index]
  load_and_authorize_resource :except=>[:index, :new, :creates]


  def index
    @circles = @user.circles.paginate(:page => params[:page],:per_page=>10)
  end

  def new
    @circle = Circle.new(:owner=>@user, :source=>@user)
  end

  def create
    @circle = Circle.new(params[:circle])
    if @circle.save
      flash[:success] = I18n.t 'circle.create.success'
      redirect_to user_circle_path(@user, @circle)
    else
      flash[:error] = I18n.t 'circle.create.error'
      render 'new'
    end

  end

  def edit
    @circle = Circle.find_by_id(params[:id])
  end

  def update
  end

  def destroy
  end

  def show
    @feed_items = @circle.feed_items(params[:page],10)
  end

end

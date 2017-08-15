class SchoolsController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource :except=>[:index]
  
  def index
    @schools = @user.schools.page(params[:page]).order('name DESC')
  end
  
  def show
  end
  
end

class Users::DocumentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  respond_to :js
  
  def index
    @documents = Document.where("circle_id IN (?)", @user.circles).paginate(:page=>params[:page], :per_page=>(params[:per_page]||10))
  end

  def show
  end

  def destroy
    @document.destroy
  end

end
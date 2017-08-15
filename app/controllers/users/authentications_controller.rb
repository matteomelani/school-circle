class Users::AuthenticationsController  < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :user
  load_and_authorize_resource :authentication, :through => :user
  
  
  def destroy
    @authentication.destroy
    flash[:success] = "Successfully destroyed authentication."  
    redirect_to :back
  end  
  
end

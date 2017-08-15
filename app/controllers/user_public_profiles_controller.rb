class UserPublicProfilesController < ApplicationController

  before_filter :authenticate_user!
  
  def show
    @object_user = User.find(params[:id])
  end
  
end
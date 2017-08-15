class MembershipsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
    
  respond_to :json
  
  def create   
    @membership = Membership.create!(params[:membership])
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
  
  def destroy
    @membership.destroy
    logger.info("Membership successfully deleted returning: #{@membership}")
    respond_with(@membership)  
  end
  
    
end
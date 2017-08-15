class Groups::MembershipsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :group
  load_and_authorize_resource :circle, :through=>:group, :singleton=>true
  load_and_authorize_resource :membership, :through=>:circle
  
  def index
    @memberships = @circle.memberships.paginate(:page=>params[:page], :per_page=>10)
    @members = @circle.members.paginate(:page => params[:page],:per_page=>10)
  end
  
  # def create   
  #     @membership = Membership.create!(params[:membership])
  #     respond_to do |format|
  #       format.html { redirect_to :back }
  #       format.js
  #     end
  #   end
  #   
  #   def destroy
  #     @user = current_user
  #     Membership.find(params[:id]).destroy
  #     respond_to do |format|
  #       format.html { redirect_to :back }
  #       format.js
  #     end
  #   end
    
end
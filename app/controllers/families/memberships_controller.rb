class Families::MembershipsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :family
  load_and_authorize_resource :circle, :through=>:family, :singleton=>true
  load_and_authorize_resource :membership, :through=>:circle

  
  def index
    @memberships = @circle.memberships.paginate(:page=>params[:page], :per_page=>10)
    @members = @circle.members.paginate(:page => params[:page],:per_page=>10)
  end
    
end
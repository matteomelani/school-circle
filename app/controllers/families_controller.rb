class FamiliesController < ApplicationController
  
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:new, :create, :remove_member]
  respond_to :html, :json, :js
  
  def new
    @family = Family.new(:user=>@user)
    if @family.location.nil?
      @family.location = Location.new
      @family.location.input_string = @user.profile.location.input_string if @user.profile.location
    end
  end

  def create
    #TODO: this conversion code should go in the model but I have not figured out a way to 
    # make it work yet.
    params[:family]["languages"] = params[:family]["languages"].split(",")
    
    @family = Family.new(params[:family])
    @family.user = @user
   
    
    # user can only have one my-family membership at the time
    if @user.my_family
      my_family_membership = Membership.find_by_user_id_and_circle_id(@user.id, @user.my_family.circle.id)
      my_family_membership.roles.delete Family::MY_FAMILY
      my_family_membership.save!
    end
    
    if @family.save
      Zfile.set_attachable(params[:avatar_id], @family) if params[:avatar_id]
      flash[:success] = I18n.t 'controllers.families.create.success', :family_name=>@family.display_name
      redirect_to edit_family_path(@family)
    else
      flash[:error] = I18n.t 'controllers.families.create.error', :family_name=>@family.display_name
      render 'new'
    end
  end

  def show
  end

  def edit
    # session[:child_registration_hash]= { 
    #       'profile_attributes' => {
    #         'location' => @user.profile.location,
    #         'time_zone' => @user.profile.time_zone,
    #         'when_confirmed' => Time.now,
    #         'avatar_id' => nil
    #         },
    #       'memberships' => [ { :circle_id => @family.circle.id, :roles => [Family::KID_ROLE] } ] 
    #     }
  end

  def update
    #TODO: this conversion code should go in the model but I have not figured out a way to 
    # make it work yet.
    params[:family]["languages"] = params[:family]["languages"].split(",")
    if @family.update_attributes(params[:family])
      Zfile.set_attachable(params[:avatar_id], @family) if params[:avatar_id]
      flash[:success] = I18n.t 'controllers.families.update.success', :family_name=>@family.display_name
      redirect_to edit_family_path(@family)
    else
      flash[:error] = I18n.t 'controllers.families.update.error', :family_name=>@family.display_name
      render 'edit'
    end
  end
  
  def destroy
    @family.children.each do |c|
      c.destroy
    end
    @family.destroy
    flash[:success] = I18n.t 'controllers.families.destroy.success'
    redirect_to new_family_path
  end
end

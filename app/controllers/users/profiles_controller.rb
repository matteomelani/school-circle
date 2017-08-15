class Users::ProfilesController < ApplicationController
  
  before_filter :log_session, :authenticate_user!
  load_and_authorize_resource :user
  load_and_authorize_resource :profile, :through => :user, :singleton => true
  
  def show
  end
  
  def edit
    @profile.location = Location.new if @profile.location.nil?    
    if (@profile.phone_numbers.select {|a| a.name=="Home"}).count == 0
      @profile.phone_numbers.build(:name=>"Home", :number=>"")
    end
    if (@profile.phone_numbers.select {|a| a.name=="Mobile"}).count == 0
      @profile.phone_numbers.build(:name=>"Mobile", :number=>"")
    end
    if (@profile.phone_numbers.select {|a| a.name=="Work"}).count == 0
      @profile.phone_numbers.build(:name=>"Work", :number=>"")
    end
  end
  
  def log_session
     logger.info(session.inspect)
  end
  
  def update    
    if params[:avatar_id]
      Zfile.set_attachable(params[:avatar_id], @profile)
    end    
    
    if params[:profile][:location_attributes][:input_string].blank?
      params[:profile][:location_attributes][:_destroy]=1
    end
    
    # if a phone number is empty then we destroy the record if it exists
    # TODO: dry it up!
    pns={}
    params[:profile][:phone_numbers_attributes].each do |key, value|
      pns[key]=value
      if value[:number].blank?
        pns[key]=value.merge({:_destroy=>"1"})
      end
    end
    params[:profile][:phone_numbers_attributes]=pns    
    
    if @profile.update_attributes(params[:profile])
      @profile.when_confirmed=Time.now if @profile.when_confirmed.blank?
      @profile.save!
      flash[:success] = I18n.t 'controllers.users.profiles.update.success'
      redirect_to edit_user_profile_path(@user)    
    else
      flash.now[:error] = I18n.t 'controllers.users.profiles.update.error' 
      render 'edit'
    end
    
  end


end
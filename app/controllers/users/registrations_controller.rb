class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :authenticate_user!, :except=> [:new, :create]
  load_and_authorize_resource :user, :except=> [:new, :create, :welcome_message]
  #force_ssl :only=>[:new, :create, :update]
  
  def new
    
    # If there is an invitation for this user get the attributes for the registration form from it.
    # Get the email, first and last name; the user supply the password or can choose to use a 3rd
    # party service to sign up. The rest of the info in the registration_hash will be applied
    # in the create action.
    @invitation = Invitation.find_by_token_and_is_used(params[:token], false)
    if @invitation and current_user and @invitation.email != current_user.email
      sign_out current_user
    end  
    if @invitation
      session['registration_hash'] = { 
        :email=> @invitation.email#,
        # :profile_attributes=>{
        #           :first_name=>@invitation.registration_hash[:profile_attributes][:first_name],
        #           :last_name=>@invitation.registration_hash[:profile_attributes][:last_name]
        #         }
      }
      session['invitation_token'] = @invitation.token  
    end
    @user = super
  end
  
  def create
    # if the user got here through an invitation then the session has the invitation token 
    # to retrieve the invitation object and the registration info contained in the invitation.
    # The super::create method uses the session['registration_hash'] to build a user object.
    if session['invitation_token']
      @invitation = Invitation.find_by_token_and_is_used(session['invitation_token'], false)
      session['registration_hash'] = @invitation.registration_hash
    end
    
    # implementation from super class: it invokes user.new_with_session
    # it also define the instace variable @user
    build_resource
    
    # this is the user that is build by the build_resource call, that method uses the registration_hash in the session 
    # to build the user   
    user_built_from_registration_hash = self.resource
    
    # this is the user build from the form values submitted by the user
    user_built_with_form = User.new(params[:user])
    
    # this is the final user object, values submitted by the user with the registration form 
    # override values set in the registration_hash
    user =  user_built_from_registration_hash
    user.email = user_built_with_form.email
    user.password = user_built_with_form.password
    user.profile.first_name = user_built_with_form.profile.first_name
    user.profile.last_name = user_built_with_form.profile.last_name
    
    if user.save
      if user.confirmed?
        sign_in_and_redirect(resource_name, user)
      else
        expire_session_data_after_sign_in!
        @user_email = user.email
        @user_name = user.profile_first_name
        render 'users/registrations/welcome_message'
      end
    else
      clean_up_passwords(user)
      render_with_scope :new
    end

    # The user has been created so now accept the invitation to join a circle
    if @invitation
      @user.accept_invitation(@invitation)
    end
    # Clean up the session
    session['invitation_token'] = nil if session['invitation_token']
    # The registration_hash is used to support authentication through 3rd party
    # services like Facebook. When a user sign in for the very first time
    # using a 3rd party service and the sign up process fails due to missing
    # information from the 3rd party service we redirect the user to the
    # standard sign up page and we store the info provided by the 3rd party
    # service in the session so that we can partially compile the form for the
    # user.
    # 
    # See: User.new_with_session method.
    session['registration_hash'] = nil if session['registration_hash']
  end
 
  # PUT /resource
   def update
     if resource.update_with_password(params[resource_name])
       set_flash_message :success, :updated if is_navigational_format?
       sign_in resource_name, resource, :bypass => true
       respond_with resource, :location => after_update_path_for(resource)
     else
       clean_up_passwords(resource)
       respond_with_navigational(resource){ render_with_scope :edit }
     end
   end
   
  # DELETE /resource
  def destroy
    resource.destroy
    #sign_out_and_redirect(self.resource)
    redirect_to root_path
    set_flash_message :notice, :destroyed
  end
     
  # The path used after sign up.
  def after_sign_in_path_for(resource)
    user_path(current_user)
  end

  def after_update_path_for(resource)
    edit_user_account_path(@user)
  end
   
  def welcome_message
    @user_email = "@gmail.com"
    @user_name = "Gonzo"
  end 
end
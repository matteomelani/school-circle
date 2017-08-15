class ApplicationController < ActionController::Base

  before_filter :set_time_zone, :set_user

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    flash[:alert] = "You are not authorized to access the page you have requested."
    redirect_to root_url
  end
 
  # Custom HTLM pages for errors. 
  # See: http://www.ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages 
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end
     
    
  protected

  def set_time_zone
    Time.zone = current_user.profile_time_zone if current_user
  end

  # It sets @user to the user identified by :user_id. If :user_id is not
  # present in the url then @user is set to current_user.
  # Note that for urls like /users/:id the UserController needs to override 
  # this method and make sure to set @user to the user identified by :id otherwise
  # the authorization mechanism will not work.    
  def set_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
  end
  
  
  private
  
  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    respond_to do |format|
      format.html { render template: 'errors/error_500', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end
  
  # This method overrides the default URL the user is redirected after it has
  # signed out. See the Devise documentation for more details.
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  # This method overrides the default URL the user is redirected after it has
  # signed in. See the Devise documentation for more details.
  def after_sign_in_path_for(resource_or_scope)
    #TODO: fix the welcome page redirection mechanism
    # if current_user.sign_in_count <= 3 
    #       user_welcome_path(current_user)
    #     else
      user_path(current_user)
    # end
  end

end
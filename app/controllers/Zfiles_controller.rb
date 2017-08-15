class ZfilesController < ApplicationController

  # see these for an explanation: 
  #  http://blog.bitcrowd.net/uploadify-paperclip-rails-3-and-sessions/
  #  http://ariejan.net/2011/03/27/rails-3--devise--uploadify--no-flash-session-hacks/
  #  
  # the code I used as a template is here:
  #   https://github.com/websymphony/Rails3-Paperclip-Uploadify
  #
  # basically authentication happens through cookie session and not devise.  
  #
  before_filter :authenticate_user! 
  respond_to :json
  
  # TODO: understand what is going on here!
  # Without this statement every file upload in IE will cause the session to be reset.
  protect_from_forgery :except => :create
   
  def create
    newparams = coerce(params)
    @zfile = Zfile.new(newparams[:zfile])    
    @user = current_user
    @zfile.user= @user # set the owner of the zfile
    if @zfile.save
      rv={ :result=>'success', :zfile_id=>@zfile.id , :zfile_name=>@zfile.name, :zfile_url=> (URI(@zfile.url).relative?  ? (root_url+"assets/"+@zfile.url) : @zfile.url) }
      logger.info("zfile uploaded returning: #{rv}")
      render :json=>rv,  :status=>200 #OK
    else
      rv = { :result=>'error', :message=>"#{zfile.errors}" }
      logger.error("Cannot upload zfile returning: #{rv}")
      render :json=>rv, :status=>400 #Bad request      
    end
  end

  def destroy
    @zfile=Zfile.find(params[:id])
    if @zfile
      @zfile.destroy
      rv={ :result=>'success', :zfile_id=>params[:id] }
      status=200
      logger.info("zfile successfully deleted returning: #{rv}")
    else
      rv = { :result=>'error', :message=>"zfile with id #{params[:id]} cannot be found" }
      status=404
      logger.error("Failed to destroy zfile returning: #{rv}")
    end  
    render :json=>rv, :status=>status
  end
  
  private
  
  # This method takes the params posted by Uploadify and returns a set of params that are Rails compatible.
  def coerce(params)
    if params[:zfile].nil? 
      h = Hash.new 
      h[:zfile] = Hash.new 
      h[:zfile][:asset] = params[:Filedata] 
      h[:zfile][:asset].content_type = MIME::Types.type_for(h[:zfile][:asset].original_filename)[0].to_s
      h[:zfile][:user_id] = params[:user_id]
      h
    else 
      params
    end 
  end

end
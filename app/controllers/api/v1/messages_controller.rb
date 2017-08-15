class Api::V1::MessagesController < ApplicationController
  require 'mail'
  # disable csrf protection for the controller: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html
  skip_before_filter :verify_authenticity_token
  
  # POST /api
  def create
    puts params.to_s
    @circle = Circle.find_by_random_name((params[:to].split("@")[0].downcase).delete("<"))
    if @circle.nil?
      msg = "Rejecting post through email for #{params[:to]}. Circle is unkown!"
      logger.error(msg)
      render :text => 'success: #{msg}', :status => 404 # a status of 404 would reject the mail
      return
    end
    sender = User.find_by_email(params[:from].downcase)
    if sender.nil?
      msg = "Rejecting post through email from #{params[:from]}. User is unknown!"
      logger.error(msg)
      render :text => 'success: #{msg}', :status => 200 # a status of 404 would reject the mail
      return
    end
    
    raw_message = Mail.new(params[:message])
    if params[:html] 
      content = params[:html] 
    else
      content = params[:plain]
    end
    
    # Processs attachments
    zfile_ids = []
    if params[:attachments]
      params[:attachments].each do |name, value|
        # Load it on Amazon S3
        puts "url=#{value['url']}, name=#{value['file_name']}, content type=#{value['content_type']}"
        s3=S3Storage.new(:bucket=>CLOUDMAILIN_CONFIG['attachments_s3_bucket'])
        url_p = (value['url'].split('?')[0]) # take the url without parameters
        key = url_p.split('/').last #take only the file name
        if CLOUDMAILIN_CONFIG['path']
          key = CLOUDMAILIN_CONFIG['path'] + '/' + url_p.split('/').last 
        end
        s3.make_public(key)
        zfile = Zfile.new(:remote_url=>"#{value['url']}")
        zfile.save!
        zfile.name=value['file_name']
        zfile.save!
        zfile_ids << zfile.id
      end
    end
    
    @message = Message.new(:sender=> sender, :circle_id=>"#{@circle.id}", :title=>"#{params[:subject]}", :content=>content)
    @message.zfile_ids = zfile_ids
    if @message.save
      logger.info("Post through email was successfully. New message id is #{@message.id}")
      render :text => 'success', :status => 200
    else
      logger.info("Post through email failed.")
      render :text => 'failure: #{message.errors}', :status => 404 # a status of 404 would reject the mail
    end
  end
  
end

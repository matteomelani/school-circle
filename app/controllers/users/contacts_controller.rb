class Users::ContactsController  < ApplicationController
  require 'net/http'
  require 'net/https'
  require 'uri'
  
  
  before_filter :authenticate_user!
  respond_to :html, :json
  
  def index
    @contacts = @user.postable_circles.map! {|c| {:label=>c.name,:value=>c.name, :id=>c.id, :type=>c.class.name, :category=>c.source.class.name.pluralize} if (c.name =~ /#{params[:term]}/i)  }
    respond_with(@contacts.compact.sort { |a,b| (a[:category]+a[:label]).downcase<=>(b[:category]+b[:label]).downcase})
  end


  def search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
  
  
  
  
  #THIS METHOD TO SEND USER TO THE GOOGLE AUTHENTICATION PAGE.
  def authenticate
    # initiate authentication w/ gmail
    # create url with url-encoded params to initiate connection with contacts api
    # next - The URL of the page that Google should redirect the user to after authentication.
    # scope - Indicates that the application is requesting a token to access contacts feeds.
    # secure - Indicates whether the client is requesting a secure token.
    # session - Indicates whether the token returned can be exchanged for a multi-use (session) token.
    next_param =  authorise_user_contacts_url(@user)
    scope_param = "https://www.google.com/m8/feeds/"
    session_param = "1"
    root_url = "https://www.google.com/accounts/AuthSubRequest"
    query_string = "?scope=#{scope_param}&session=#{session_param}&next=#{next_param}"
    redirect_to root_url + query_string
  end

  # YOU WILL BE REDIRECTED TO THIS ACTION AFTER COMPLETION OF AUTHENTICATION PROCESS WITH TEMPORARY SINGLE USE AUTH TOKEN.
  def authorise
    #FIRST SINGLE USE TOKEN WILL BE RECEIVED HERE..
    token = params[:token]
    #PREPAIRING FOR SECOND REQUEST WITH AUTH TOKEN IN HEADER.. WHICH WILL BE EXCHANED FOR PERMANENT AUTH TOKEN.
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = '/accounts/AuthSubSessionToken'
    headers = {'Authorization'=>"AuthSub token=#{token}"}

    #GET REQUEST ON URI WITH SPECIFIED PATH...
    resp, data = http.get(path, headers)
    #SPLIT OUT TOKEN FROM RESPONSE DATA.
    if resp.code == "200"
      token = ''
      data.split.each do |str|
        if not (str =~ /Token=/).nil?
          token = str.gsub(/Token=/, '')
        end
      end  
      return redirect_to(:action => 'import', :token => token)
    else
      redirect_to root_url , :notice => "fail"
    end
  end

  #USING PERMANENT TOKEN IN THIS ACTION TO GET USER CONTACT DATA.
  def import
    # GET http://www.google.com/m8/feeds/contacts/default/base
    token = params[:token]
    uri = URI.parse("https://www.google.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    path = "/m8/feeds/contacts/default/full?max-results=10000"
    headers = {'Authorization' => "AuthSub token=#{token}", 'GData-Version' => "3.0"}
    resp, data = http.get(path, headers)
    # extract the name and email address from the response data
    # HERE USING REXML TO PARSE GOOGLE GIVEN XML DATA
    xml = REXML::Document.new(data)
    contacts = []
    xml.elements.each('//entry') do |entry|
      person = {}
      person['name'] = entry.elements['title'].text
      gd_email = entry.elements['gd:email']
      logger.debug(entry)
      if gd_email
        person['email'] = gd_email.attributes['address'] 
        @user.profile.contacts << person if person
      end 
    end
    @user.profile.save
    redirect_to root_url , :notice => "imported successfully"
  end
  
end
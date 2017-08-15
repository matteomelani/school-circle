class RemindersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:new]
  respond_to :js, :html, :json
  
  def new
    @reminder = Reminder.new
    respond_to do  |format|
       format.js {}
       format.html{}
       format.json {}
    end
  end

  def create
    @reminder.sender=@user
    if @reminder.save
      respond_to do  |format|
         format.js {}
         format.html{ redirect_to @user }
         format.json {}
      end
    else
      respond_to do  |format|
         format.js {}
         format.html{ logger.error(@reminder.errors); render 'new' }
         format.json {}
      end
    end
  end

  def show
    respond_to do  |format|
       format.js {}
       format.html{}
       format.json {}
    end
  end

end

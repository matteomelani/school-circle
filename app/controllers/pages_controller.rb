class PagesController < ApplicationController

  def home
    if user_signed_in?
      flash.keep
      redirect_to current_user  
    end
  end
  
  def coming_soon
  end
  
  def about
  end
 
  def help
  end
  
  def create_interested_people
    @interested_people = InterestedPeople.new(params[:interested_people])
    if @interested_people.save
      flash[:notice] = "Thanks! We will let you know as soon as we launch!"
      redirect_to root_path
    else
      flash[:error] = "Oops! I did not quite get the email, can you check the spelling? Thanks!"
      render :action=>"coming_soon"
    end
  end
  
end

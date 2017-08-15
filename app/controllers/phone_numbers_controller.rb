class PhoneNumbersController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:new, :create]

  def new
    @phone_number = PhoneNumber.new()
  end

  def create
    @phone_number = User.new(params[:phone_number])
    authorize! @phone_number

    if @phone_number.save
      respond_to do |format|
       format.js
      end
    else
     flash[:error] ="wrong phone number"
    end

  end

  def show
    @phone
  end

end

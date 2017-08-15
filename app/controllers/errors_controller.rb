# Custom HTLM pages for errors. 
# See: http://www.ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
class ErrorsController < ApplicationController
  def error_404
    @not_found_path = params[:not_found]
  end

  def error_505
  end

end

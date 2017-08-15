class Users::ConnectionsController  < ApplicationController

  before_filter :authenticate_user!
  respond_to :html, :json

  def index
    types=params[:types]
    @connections = []
    if types.include? 'users'
      # see http://www.postgresql.org/docs/9.0/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP
      users = Profile.find(:all, :conditions=>['first_name ~* ? OR last_name ~* ?', "#{params[:term]}", "#{params[:term]}"])
      @connections.concat users.map! {|u| {:label=>u.full_name, :value=>u.full_name, :email=>u.user.email, :name=>u.full_name, :id=>u.user.id, 
                                           :type=>u.user.class.name, :category=>u.class.name.pluralize} if (u.full_name =~ /#{params[:term]}/i)  }
    end
    if types.include? 'contacts'
      #@connections = @user.postable_circles.map! {|c| {:label=>c.name,:value=>c.name, :id=>c.id, :type=>c.class.name} if (c.name =~ /#{params[:term]}/i)  }
    end
    if types.include? 'circles'
      @connections.concat @user.postable_circles.map! {|c| {:label=>c.name,:value=>c.name, :id=>c.id, :type=>c.class.name, 
                                                            :category=>(c.source.class.name=="User" ? "Personal Circles" : c.source.class.name.pluralize )} if (c.name =~ /#{params[:term]}/i)  }
    end
    if types.include? 'neighbours'
      @connections.concat @user.neighbours.map! {|u| {:label=>u.profile_full_name, :value=>u.profile_full_name, :email=>u.email, :name=>u.profile_full_name, 
                                                      :id=>u.id, :type=>u.class.name, :category=>u.class.name.pluralize, :desc=>"@#{u.username}"} if (u.profile_full_name =~ /#{params[:term]}/i)  }
    end

    respond_with(@connections.compact.sort { |a,b| (a[:category]+a[:label]).downcase<=>(b[:category]+b[:label]).downcase})
  end

  def search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end

end
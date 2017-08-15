require 'active_record'

# For a class to have an avatar you need to:
#  - include HasAvatar
#  - call has_avatar
#  - in the controller CREATE add after the save method is successful: Zfile.set_attachable(params[:avatar_id], @family) if params[:avatar_id]
#  - in the controller UPDATE add after the update_attributes is successful: Zfile.set_attachable(params[:avatar_id], @family) if params[:avatar_id]
#  - in the view make sure that when the profile photo is modified an :avatar_id hidden field is included in the object form
module HasAvatar
  
  DEFAULT_PHOTO_URL = "user_original.png"
  
  # self.included is invoked when a class inlcude the module
  def self.included(base)
    base.extend ClassMethods  # add the ClassMethods to the including class 
  end
  
  module ClassMethods

    def has_avatar
      has_one :avatar, :class_name=>"Zfile", :as=>:attachable, :dependent=>:destroy          
      accepts_nested_attributes_for :avatar, :allow_destroy=>true, :reject_if=>:all_blank
      
      include InstanceMethods
    end
    
    def default_avatar_url
      DEFAULT_PHOTO_URL
    end
    
  end

  module InstanceMethods
    
    def default_avatar_url
      @default_avatar_url = @default_avatar_url || DEFAULT_PHOTO_URL
    end
    
    def default_avatar_url=(url)      
      @default_avatar_url = url
    end
    
    def using_default_avatar?
      avatar.nil?
    end
    
    def avatar_url(size=:medium)
      if avatar.nil?
        default_avatar_url.gsub("_original.", "_#{size.to_s}.")
      else
        avatar.url.gsub("_original.", "_#{size.to_s}.")
      end
    end

    def avatar_url=(remote_url)
      if remote_url.nil?
        #user wants to delete existing avatar and revert to default
        avatar.destroy if avatar
        return
      end
      if avatar
        avatar.remote_url = remote_url
      else
        create_avatar :remote_url=>remote_url, :user_id=>self.user_id
      end
    end    
  end


end
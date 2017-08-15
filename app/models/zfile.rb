# TODO: specs out the class behavior
# it reppresents a file store somewhere
# input can be a local file or a url
#     if it is a url the class will download the file first that save to the store
class Zfile < ActiveRecord::Base

  belongs_to :attachable, :polymorphic => true
  belongs_to :user
  
  # allows paperclip to work with a remote url not just a file
  attr_accessor :remote_url
  before_validation :download_remote_file, :if => :is_file_source_a_remote_url?
  
  has_attached_file :asset, 
                      { :whiny_thumbnails=>true,
                        :styles => { :small=>"32x32#", :medium=>"48x48#", :large=>"72x72#"}
                      }.merge(Rails.application.config.paperclip_storage_options)
  before_post_process :set_name, :randomize_filename, :set_url
  before_post_process :is_image?
  
  def is_image?
    ["image/jpeg", "image/pjpeg", "image/png", "image/x-png", "image/gif"].include?(self.asset_content_type) 
  end
  
  def is_doc?
    ["application/pdf", "application/word", "application/msword"].include?(self.asset_content_type) 
  end
  
  has_ipaper_and_uses 'Paperclip'

  def self.set_attachable(file_id, attachable)
    unless file_id
      return false
    end
    # old asset need to be deleted
    attachable.avatar.destroy if attachable.avatar
    #find new file (the one that was just loaded)
    saved_file = Zfile.find(file_id)
    if saved_file
      saved_file.attachable = attachable
      saved_file.save!
    else
      logger.error("Cannot attach file with id #{file_id} because there is not file in the DB with that id.")
    end
    return true
  end

  
    
  private 
  
  # Randomize the filename we use to store the asset on Amazon S3. This is for security reson since all the
  # files are public. The name is hard to guess therefore secure.
  def randomize_filename
    extension = File.extname(asset_file_name).downcase
    self.asset.instance_write(:file_name, "#{SecureRandom.hex.first(16)}#{extension}")
  end
  
  # The following 2 methods set the value of the asset name and its url. The name is the file name 
  # of the asset while the url is the absolute url that can be used to retrive the asset.
  def set_name
    self.name = self.asset.original_filename
  end
  
  def set_url
    self.url=self.asset.url
  end
  
  # The followinf 3 methods allows to upload an asset simply by setting the attribute source_url.
  # The code was stolen from: http://trevorturk.com/2008/12/11/easy-upload-via-url-with-paperclip/
  def is_file_source_a_remote_url?
    !self.remote_url.blank?
  end
  
  def download_remote_file
    self.source_url = self.remote_url
    self.asset = do_download_remote_file(self.remote_url)
    # it is important to set the remote_url to nil otherwise when scribd_fu update the asset object again
    # the remote asset is downloaded again an paperclip re-save the file on s3. Besides being a waste of
    # resources it also gives to scribd.com a url that is not valid.
    self.remote_url=nil
  end
  
  def do_download_remote_file(url)
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  end
  
end

### Avatars ###
# Avatars images are generated in the following way:
#
#  1)  Generate properly sized images: given a directory with images (png or jpg) 
#      we run the avatar_resize.rb script on it which output the images directory 
#      that contains all pngs properly resized.
#
#  2)  Generate images metadata: we now run the extract_metadata.rb script on the 
#      images directory, this script extract the images metadata and writes them 
#      to a yaml file: a map where the keys are the files names and the values are
#      a map that contains info about the files.
#
#  3)  Seeds.rb loads the avatars_metadata.yaml file (output of step 2)
#
#  4)  When you now need an avatar photo in the seeding code you can call 
#      assign_avatar and pass it
#       - has_avatar is a reference to the object that include the has_avatar 
#         module, i.e. a user.profile or classroom or group
#       - base_path is the base path or url where the png file is located,
#         this is could be a local path or a remote url
#   

class AvatarLoader
  
  AVATARS_METADATA_FILE = "#{Rails.root}/config/data/avatars_metadata.yaml"
  DEFAULT_SEED_AVATAR_BASE_URL = "content/seed_avatars"   
  
  def initialize
    puts "Loading avatars metadata from #{AVATARS_METADATA_FILE}"
    @avatars_metadata = YAML::load(File.read(AVATARS_METADATA_FILE))
    puts "done."
    puts "Getting avatars base url from environment variable DEFAULT_SEED_AVATARS_BASE_URL"
    @avatars_base_path = ENV["DEFAULT_SEED_AVATARS_BASE_URL"]
    unless ENV["DEFAULT_SEED_AVATARS_BASE_URL"]
      puts "DEFAULT_SEED_AVATARS_BASE_URL is not defined. Using default value: #{DEFAULT_SEED_AVATAR_BASE_URL}"      
      @avatars_base_path = DEFAULT_SEED_AVATAR_BASE_URL
    end 
    puts "Avatars Base URL set to: #{@avatars_base_path}"
    if @avatars_base_path.nil? 
      raise "Seed avatar diretory is nil. The deafault local dir #{DEFAULT_SEED_AVATAR_BASE_URL} does not exists and the Env variable DEFAULT_SEED_AVATARS_BASE_URL is not defined. (Look at https://s3.amazonaws.com/seed-data/random_avatars)"
    end
  end
  
  def load file_name
    raise "bad extension for file - #{File.extname(file_name)} - " if File.extname(file_name) != ".png"
    raise "I 've got no info about avatar: #{file_name}. Check the avatars_metadata.yaml file." unless @avatars_metadata[file_name]
    avatar = {:url => "#{@avatars_base_path}/#{file_name}", :asset_updated_at => Time.now }.merge(@avatars_metadata[file_name])
  end

end
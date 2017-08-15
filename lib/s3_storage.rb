require 'aws/s3'

class S3Storage
  include AWS::S3  

  attr_reader :bucket
  
  # By deafult it loads the s3 account information and the bucket from Rails.root/config/s3.yml.
  # you can override that with the following:
  # :config_file
  # :bucket
  # :id_key
  # :secret_key
  def initialize(args={})
    @config_file =  args[:config_file] || "#{Rails.root}/config/s3.yml"
    config_hash = YAML.load_file(@config_file)
    @bucket = args[:bucket] || config_hash[Rails.env]['bucket']
    @id_key = args[:id_key] || config_hash[Rails.env]['access_key_id']
    @secret_key = args[:secret_key] || config_hash[Rails.env]['secret_access_key']
    AWS::S3::Base.establish_connection!(:access_key_id=>@id_key,:secret_access_key=>@secret_key)
  end

  # Changes the ACL of a single object so that the object is readable by any user.
  def make_public(key)
    policy = S3Object.acl(key, @bucket)
    policy.grants << ACL::Grant.grant(:public_read)
    policy.grants << ACL::Grant.grant(:public_read_acp)
    S3Object.acl(key, @bucket, policy)      
  end
  
  # Write a file on S3 and return the url to fetch it
  def write_file(key, file_path)
    S3Object.store key, open(file_path), @bucket
    o = S3Object.find key, @bucket
    o.url
  end

  def delete_file(key)
     S3Object.delete key, @bucket
  end

  private
  def connect

  end

end
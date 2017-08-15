require 'spec_helper'

describe S3Storage, :online=>true do
  include AWS::S3
  let(:storage){ S3Storage.new }
  
  it "loads s3 keys from config/s3.yml and establish connection" do
     storage.bucket.should == "tsc-test"
  end
  
  describe "#make_public" do
    it "takes the path (key) to a file and make the file readable by every user" do

      #write a file to the bucket
      file_path = "./tmp/test_#{Time.now.to_i}"
      File.open(file_path, "w") do |f|
        f.puts "this is a test"
      end 
      key=File.split(file_path)[1]
      S3Object.store key, open(file_path), storage.bucket

      #http get it should fails
      o = S3Object.find key, storage.bucket
      public_url = o.url.split("?")[0]
      # puts public_url
      url = URI.parse(public_url)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      res.instance_of?(Net::HTTPForbidden).should be_true  
      #make it public
      storage.make_public(key)

      #http get should work now
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      res.instance_of?(Net::HTTPOK).should be_true  

      #delete file locally and on s3
      File.delete file_path
      S3Object.delete key, storage.bucket
   
    end
  end
  
end
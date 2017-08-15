require 'spec_helper'


describe Zfile do

  let(:zfile) { Factory(:zfile) }

  it "is valid with valid attributes" do
    zfile.should be_valid
  end 

  it "accepts a file" do
    # stub Paperclip method so that we do not save on s3 
    zfile.stub(:save_attached_files).and_return(true)
    zfile.stub(:destroy_attached_files).and_return(true)
    # stub Sribd_fu so that we do not upload on scribd.com
    zfile.stub!(:scribdable? => false)

    zfile.asset = File.open("#{Rails.root}/spec/fixtures/word.doc")
    zfile.stub!(:has_ipaper_and_uses)
    zfile.save!
    zfile.name.should == "word.doc"
    zfile.url.should == zfile.asset.url
    zfile.source_url.should be_blank
    zfile.asset_file_name.should_not == "word.doc" # random name 
    zfile.asset_content_type.should == "application/msword"
    zfile.asset_file_size.should == 24064     
  end

  it "accepts a url" do
    
    # stub Paperclip method so that we do not save on s3 
    zfile.stub(:save_attached_files).and_return(true)
    zfile.stub(:destroy_attached_files).and_return(true)
    
    # stub Sribd_fu so that we do not upload on scribd.com      
    zfile.stub!(:scribdable? => false)
    zfile.stub!(:do_download_remote_file) { open("#{Rails.root}/spec/fixtures/word.doc") }
    
    url = "http://www.somelocation.com/word.doc"

    # this will download the zfile
    zfile.remote_url = url
    zfile.save!

    # are the db field set correctly
    zfile.source_url.should == url    
    zfile.name.should == "word.doc"
    zfile.url.should == zfile.asset.url
    zfile.asset_file_name.should_not == "test.doc" # random name 
    zfile.asset_content_type.should == "application/msword"
    zfile.asset_file_size.should == 24064
   
    # this is our remote zfile.
    # s3 = S3Storage.new("#{Rails.root}/config/s3.yml")
    # url = s3.write_file('test.doc', "#{Rails.root}/spec/fixtures/word.doc")
    # s3.make_public('test.doc')
    # s3.delete_file('test.doc')
    
  end

end

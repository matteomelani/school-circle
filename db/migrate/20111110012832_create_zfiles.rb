class CreateZfiles < ActiveRecord::Migration
  def self.up
    create_table :zfiles do |t|
      t.string :name                    # this is the asset name, basically it is the original file name
      t.string :source_url              # if the asset came from a url this is the original url
      t.string :url                     # current asset url on s3
      
      t.string :asset_file_name         # paperclip field
      t.string :asset_content_type      # paperclip field
      t.integer :asset_file_size        # paperclip field
      t.datetime :asset_updated_at      # paperclip field
      
      t.string :attachable_type
      t.integer :attachable_id
      
      t.integer :ipaper_id              # scribd field, this has a value if the asset is loaded on scribd and can be viewed with the ipaper reader
      t.string :ipaper_access_key       # scribd field, this has a value if the asset is loaded on scribd and can be viewed with the ipaper reader
      
      t.integer :user_id                #user that has uploaded the asset  
      t.timestamps
    end
    
    add_index :zfiles, [:attachable_id, :attachable_type]
    add_index :zfiles, :user_id
    
  end

  def self.down
    drop_table :zfiles
  end
end

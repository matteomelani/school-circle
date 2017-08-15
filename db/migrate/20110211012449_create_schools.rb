class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string   :name
      t.enum     :category            # private, public
      t.string   :grade_range         #k-5, K-2, 6-12
      t.string   :description
      t.string   :pta_url             # parent-teacher association web site
      t.string   :web_site_url        # school web site
      t.string   :principal           # principal's name
      t.string   :photo_file_name    
      t.string   :photo_content_type
      t.integer  :photo_file_size
      t.datetime :photo_updated_at
      t.string   :photo_s3_url
      t.integer  :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schools
  end
end

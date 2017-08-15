class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      
      t.integer  :user_id
      t.timestamp :when_confirmed # time when the user has review the profile or null if never reviewed
      t.string   :first_name
      t.string   :last_name
      t.datetime :birthday
      t.enum     :sex
      t.string   :time_zone
      t.string   :location
      t.text     :geo_location_object
      t.string   :locale
      t.enum     :main_role
      t.text     :about
      
      t.timestamps
    end
    
     add_index :profiles, :user_id
     add_index :profiles, :first_name
     add_index :profiles, :last_name
     
  end

  def self.down
    drop_table :profiles
  end
end

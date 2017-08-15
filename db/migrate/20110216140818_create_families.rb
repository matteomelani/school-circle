class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.string :name
      t.integer :user_id
      t.text   :geo_location_object  # serialized geolocaiton obj
      t.text   :languages            # serialized array of languages
      t.text   :about

      t.timestamps
    end
    
    add_index :families, :user_id
    
  end

  def self.down
    drop_table :families
  end
end

class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :label    # string that identify the address like : home, office, billing, ...
      t.string :line1    # Street address, P.O. box, company name, c/o
      t.string :line2    # Apartment, suite, unit, building, floor, etc.
      t.string :city
      t.integer :zipcode
      t.string :state
      t.string :country
      
      t.integer :owner_id 
      t.string :owner_type
      
      t.text :geo_location_object
       
      t.timestamps
    end
    
     add_index :addresses, :owner_id
     add_index :addresses, :owner_type
  end


  def self.down
    drop_table :addresses
  end
end

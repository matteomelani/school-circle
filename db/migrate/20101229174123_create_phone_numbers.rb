class CreatePhoneNumbers < ActiveRecord::Migration
  def self.up
    create_table :phone_numbers do |t|
      t.string  :name
      t.string  :number
      t.string  :extension 
      t.integer :owner_id    
      t.string  :owner_type
      
      t.timestamps
    end

    add_index :phone_numbers, :owner_id
    add_index :phone_numbers, :owner_type
    
  end


  def self.down
    drop_table :phone_numbers
  end
end

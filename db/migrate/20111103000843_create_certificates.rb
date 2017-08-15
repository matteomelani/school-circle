class CreateCertificates < ActiveRecord::Migration
  def self.up
    create_table :certificates do |t|
      t.integer :user_id
      t.integer :offer_id
      t.text :offer_snapshot     # this is a copy of the offer object at the time of the purchase
      t.integer :business_id     # business id could be read from the offer but we want to give easy query access to it
      t.integer :school_id       # school id could be read from the offer but we want to give easy query access to it
      t.integer :transaction_id  # unique identifier for the payment system
      t.float :cost              # cost to user
      t.float :value             # value to user
      t.float :donation          # amount donated to the school
      t.float :fee               # The School Circle fee 
      t.text :note               # Notes on the certificates
      t.text :extra_info         # Has that contains any other value for the certificates
      t.datetime :purchased_on
      t.datetime :expires_on
      t.boolean  :is_used
      t.datetime :used_on
      
      
      t.timestamps
    end
    add_index :certificates, :user_id
    add_index :certificates, :offer_id
    add_index :certificates, :business_id
    add_index :certificates, :school_id
    add_index :certificates, :is_used
    add_index :certificates, :used_on
  end

  def self.down
    drop_table :certificates
  end
end

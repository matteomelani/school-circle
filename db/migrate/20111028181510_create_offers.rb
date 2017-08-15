class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.string :title
      t.string :description
      t.float  :value
      t.float  :cost
      t.datetime :start_on
      t.datetime :end_on
      t.integer :max_available
      t.integer :business_id
      t.integer :campaign_id
      t.timestamps
    end
    
    add_index :offers, :business_id
    add_index :offers, :campaign_id

  end

  def self.down
    drop_table :offers
  end
end

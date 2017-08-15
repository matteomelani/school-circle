class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
       t.string :input_string
       t.text :geo_object
       t.references :locationable, :polymorphic=>true
       t.timestamps
    end
    
  end

  
end

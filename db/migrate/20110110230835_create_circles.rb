class CreateCircles < ActiveRecord::Migration
  def self.up
    create_table :circles do |t|
      t.string  :name
      t.string  :description
      t.integer :owner_id         # user that created the circle
      t.integer :source_id        # a source can be a user, family, class or school
      t.string  :source_type
      t.string  :random_name      # random name used to assign to the circle an email for user to post
      t.string  :settings         # general JSON bag for miscellaneous settings
      
      t.timestamps
    end

    add_index :circles, :owner_id
    add_index :circles, :source_id
    add_index :circles, :source_type
    add_index :circles, :random_name, :unique => true
   
  end

  def self.down
    drop_table :circles
  end
end

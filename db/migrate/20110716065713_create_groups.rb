class CreateGroups < ActiveRecord::Migration
    def self.up
      create_table :groups do |t|
        t.string  :name 
        t.text    :about                
        t.integer :user_id              

        t.timestamps
      end

      add_index :groups, :name
      add_index :groups, :user_id
    end

    def self.down
      drop_table :groups
    end
  end

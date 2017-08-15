class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :circle_id
      t.integer :circle_source_id
      t.string  :circle_source_type
      t.text :roles
      
      t.timestamps
    end

    add_index :memberships, :user_id
    add_index :memberships, :circle_id

  end

  def self.down
    drop_table :memberships
  end
end

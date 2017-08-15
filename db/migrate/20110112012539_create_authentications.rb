class CreateAuthentications < ActiveRecord::Migration
  def self.up
    create_table :authentications do |t|
      t.integer :user_id
      t.string  :provider
      t.string  :uid
      t.string  :provider_name
      t.string  :provider_username
      t.text    :token
      
      t.timestamps
    end

    add_index :authentications, :user_id
    add_index :authentications, :provider
    add_index :authentications, :uid
    add_index :authentications, :token, :unique=>true
  end

  def self.down
    drop_table :authentications
  end
end

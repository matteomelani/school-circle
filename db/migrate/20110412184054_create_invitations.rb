class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer     :inviter_id
      t.string      :email
      t.integer     :circle_id
      t.text        :registration_info  # a flat registration_hash
      t.datetime    :sent_on
      t.datetime    :expires_on
      t.integer     :times_sent, :default=>0
      t.string      :token, :limit=>60
      t.boolean     :is_used, :default=>false
      t.text        :optional_message
      
      t.timestamps
    end
    
    add_index :invitations, :email
    add_index :invitations, :circle_id
    add_index :invitations, :token, :unique=>true
    add_index :invitations, :expires_on
    
  end

  def self.down
    drop_table :invitations
  end
end

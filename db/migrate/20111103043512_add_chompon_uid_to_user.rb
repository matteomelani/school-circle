class AddChomponUidToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :chompon_uid, :integer
  end

  def self.down
    remove_column :users, :chompon_uid
  end
end

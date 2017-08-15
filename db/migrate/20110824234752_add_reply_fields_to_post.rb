class AddReplyFieldsToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :parent_id, :integer
    add_column :posts, :thread_id, :integer
  end

  def self.down
    remove_column :posts, :parent_id
    remove_column :posts, :thread_id
  end
end

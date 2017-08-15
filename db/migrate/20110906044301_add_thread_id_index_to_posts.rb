class AddThreadIdIndexToPosts < ActiveRecord::Migration
  def self.up
      add_index :posts, :thread_id
      add_index :posts, :parent_id
  end

  def self.down
    remove_index :posts, :thread_id
    remove_index :posts, :parent_id
  end
end

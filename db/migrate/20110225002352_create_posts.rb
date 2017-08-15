class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string     :title
      t.text       :content
      t.string     :content_type
      t.text       :options      # security options, publications options, ...
      t.string     :type         # types are: messages, reminder, photo gallery(1 or more photos)
      t.integer    :receiver_id  # not nil when the post is for sent to a specific user
      t.integer    :sender_id  
      t.integer    :circle_id    # always has a value since it establish context event in the case of private messages
      t.text       :data_bag     # hash with free form data we might want to store
      t.timestamps
    end
    
    add_index :posts, :receiver_id
    add_index :posts, :circle_id
    add_index :posts, :sender_id
    add_index :posts, :type
  end

  def self.down
    drop_table :posts
  end
end

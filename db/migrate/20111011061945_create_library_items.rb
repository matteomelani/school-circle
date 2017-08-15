class CreateLibraryItems < ActiveRecord::Migration
  def self.up
    create_table :library_items do |t|
      t.string :type     # Document, photo, video, assignament, poll, etc.
      t.string :title
      t.text :note
      t.integer :circle_id
      t.integer :file_id
      t.string :source_type
      t.integer :source_id

      t.timestamps
    end
    add_index :library_items, :type    
    add_index :library_items, :circle_id
  end

  def self.down
    drop_table :library_items
  end
end

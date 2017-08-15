class AddContactsToUser < ActiveRecord::Migration
  def change
    add_column :profiles, :contacts, :text
  end
    
end

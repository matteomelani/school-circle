class CreateInterestedPeople < ActiveRecord::Migration
  def up
    create_table :interested_people do |t|
        t.string   :email
        t.timestamps
      end
  end

  def down
    drop_table :interested_people
  end
end
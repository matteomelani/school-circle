class CreateClassrooms < ActiveRecord::Migration
  def self.up
    create_table :classrooms do |t|
      t.string  :name                 # name of the class without the "classroom" word
      t.string  :teacher              # main teacher responsible for the class
      t.string  :grade_level          # k, 1st grade, 2nd grade...: P, K, 1, 2, 3...  
      t.string  :school_name          # name of the school
      t.integer :school_id            # id of the school is filled only after the classroom has been linked to the school
      t.text    :about                # a description of the class
      t.integer :user_id              # the user that created the class
      t.string  :random_code          # 5 digits code that can be used to find the class
      t.string  :school_year          # 4 digit school year
      t.enum    :school_association_status, :default=>Classroom::UNVERIFIED
      t.timestamps
    end
    
    add_index :classrooms, :name
    add_index :classrooms, :random_code, :unique=>true
    add_index :classrooms, :school_id
    add_index :classrooms, :user_id
  end

  def self.down
    drop_table :classrooms
  end
end

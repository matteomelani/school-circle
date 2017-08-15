class AddPinToCircles < ActiveRecord::Migration
  def change
    add_column :circles, :pin, :string
  end
end

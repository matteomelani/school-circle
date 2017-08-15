class RemoveLocationFromFamily < ActiveRecord::Migration
  def change
    remove_column :families, :geo_location_object
  end
end

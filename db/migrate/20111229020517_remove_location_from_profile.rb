class RemoveLocationFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, :location
    remove_column :profiles, :geo_location_object
  end
end

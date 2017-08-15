class Address < ActiveRecord::Base
  
  serialize :geo_location_object
  before_save :geolocate
   
  belongs_to :owner, :polymorphic => true
  
  validates :label,
            :length => { :maximum => 30 }

  validates :line1, :city, 
            :presence => true,
            :length => { :minimum => 2 }

  validates :state, 
            :presence => true,
            :length => { :is => 2 }

  validates :zipcode,
            :numericality => {:only_integer => true, :greater_than => 9999, :less_than => 100000  }

  validates :owner_id,
            :presence => true
  
  validates :owner_type,
            :presence => true

    
  def to_s
    sprintf("%s%s%s %s, %s %s %s", 
              (label.blank? || label.strip.blank?) ? "" : "#{label}: ", 
              line1, 
              (line2.blank? || line2.strip.blank?) ? "" : ", #{line2}", 
              city, 
              state, 
              zipcode.to_s, 
              country)
  end  
  
  private
  def geolocate
    if self.new_record? && self.geo_location_object
       return
    end
    if self.changed? 
      logger.info("Geolocating: #{self.to_s} ...")
      self.geo_location_object = GeoKit::Geocoders::GoogleGeocoder.geocode(self.to_s)
      
      unless geo_location_object.success
        errors[:base] << "Geocoding failed. Please check the address."
        return false 
      end
      logger.info("Geolocating: operation was successful, found address is #{geo_location_object.full_address}")
      self.city    = geo_location_object.city
      self.state   = geo_location_object.state
      self.country = geo_location_object.country
    end
  end
  
end




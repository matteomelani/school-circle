class Location < ActiveRecord::Base
  belongs_to :locationable
  serialize :geo_object
  
  before_save :geolocate 
  
  def to_s
    input_string
  end
  
  # private
  def geolocate
    if self.input_string && input_string_changed?  
      begin
        self.geo_object = Location::geocode(self.input_string)
        unless self.geo_object.success
          errors[:base] << I18n.t("activerecord.errors.models.profile.geocoding_failed", :location=>input_string)
          logger.error(I18n.t("activerecord.errors.models.profile.geocoding_failed", :location=>input_string))
        else
          self.input_string = "#{self.geo_object.full_address}"
        end
      rescue => ex
        logger.error(I18n.t("activerecord.errors.models.profile.geocoder_error", :type=>ex.class, :message=>ex.message))
      end
    end
  end
  
  def self.geocode address
    GeoKit::Geocoders::GoogleGeocoder.geocode(address)
  end
  
end
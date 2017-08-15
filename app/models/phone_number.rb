class PhoneNumber < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  phone_number_regex = /^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/
  validates :number,
         :length   => { :maximum => 14 },
         :format   => { :with => phone_number_regex },
         :allow_blank => true
  
  extension_regex = /^[0-9]+\z/
  validates :extension,
         :length   => { :maximum => 5 },
         :format   => { :with => extension_regex },
         :allow_blank => true
         
  validates :name,
         :length   => { :maximum => 10 }
         
  
  def to_s
    sprintf("%s%s", (name.blank? || name.strip.blank?) ? "" : "#{name}: ", number)
  end 
    
  
  
end

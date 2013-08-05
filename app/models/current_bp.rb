class CurrentBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user
  
  def self.todays_date
    Date.today.to_s(:db)
  end
  
  def self.get_ampm
    if DateTime.now.seconds_since_midnight < 43200
        ampm = "am"
    else
        ampm = "pm"
    end
    ampm
  end
  
end

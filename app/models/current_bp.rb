class CurrentBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user
  
  validates :sysbp, :diabp, :numericality => {:greater_than_or_equal_to => 1, :less_than_or_equal_to => 300}

  def self.for_date_and_ampm(date, ampm)
    where(:date => date, :ampm => ampm).order("id")
  end
end

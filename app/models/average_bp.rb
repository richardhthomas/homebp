class AverageBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user

  def self.for_date_and_ampm(date, ampm)
    where(:date => date, :ampm => ampm).order("id")
  end
end

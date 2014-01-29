class AverageBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user
  
  def self.exists_for_last_7_days?
    where("date > ?", 7.days.ago).exists?
  end
end

class CurrentBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user
  
  validates :sysbp, :diabp, :numericality => {:greater_than_or_equal_to => 1}
  
end

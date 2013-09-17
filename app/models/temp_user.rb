class TempUser < ActiveRecord::Base
  has_many :current_bps
  has_many :average_bps
  accepts_nested_attributes_for :current_bps
end

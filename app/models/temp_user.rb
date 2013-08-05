class TempUser < ActiveRecord::Base
  has_many :current_bps
end

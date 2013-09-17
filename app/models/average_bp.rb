class AverageBp < ActiveRecord::Base
  belongs_to :user
  belongs_to :temp_user
end

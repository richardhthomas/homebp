class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :rememberable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :timeoutable
  
  has_many :current_bps
  has_many :average_bps
  
  accepts_nested_attributes_for :current_bps
  
  def self.has_reading_from_last_7_days?
    average_bps.where("date > ?", 7.days.ago).exists?
  end

end

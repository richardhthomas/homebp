class AdminMessage
  include ActiveAttr::Model
  
  attribute :subject
  attribute :email
  attribute :content
  attribute :greeting
  
  validates_presence_of :subject
  validates_length_of :content, :maximum => 1500
end
class AdminMessage
  include ActiveAttr::Model
  
  attribute :subject
  attribute :email
  attribute :content
  
  validates_presence_of :subject
  validates_length_of :content, :maximum => 500
end
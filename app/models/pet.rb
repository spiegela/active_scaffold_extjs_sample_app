class Pet < ActiveRecord::Base
  belongs_to :person
  
  validates_presence_of :name, :message => "Name can't be blank"
end

class Person < ActiveRecord::Base
  has_many :pets
  
  validates_presence_of :name, :message => "Name can't be blank"
end

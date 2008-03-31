module PeopleHelper
#  def pets_column(record)
#    link_to_remote(record.pets.first(3).collect{|pet| h(pet.to_label)}.join(', '),
#      :url => {:action => 'nested', :associations => 'pets', :id => record.id} ).gsub(/'/, "\"")
#  end
end
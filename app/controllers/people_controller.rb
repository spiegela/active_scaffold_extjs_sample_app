class PeopleController < ApplicationController
  active_scaffold :person do |config|
    config.columns  = [:name, :address, :city, :state, :pets]  
    config.list.columns  = [:name, :address, :city, :state, :pets]
    config.create.columns = [:name, :address, :city, :state]
    config.update.columns = [:name, :address, :city, :state]
    config.frontend = 'extjs'
    config.actions.swap :search, :live_search
  end
end
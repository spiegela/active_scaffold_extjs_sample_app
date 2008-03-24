class PetsController < ApplicationController
  active_scaffold :pet do |config|
    config.columns = [:name, :type, :breed, :person]
    config.frontend = 'extjs'
  end
end

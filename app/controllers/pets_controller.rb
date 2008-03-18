class PetsController < ApplicationController
  active_scaffold :pet do |config|
    config.frontend = 'extjs'
  end
end

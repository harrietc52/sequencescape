# frozen_string_literal: true

require 'test_helper'
require 'rails/performance_test_help'

class PlateCreationTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  self.profile_options = { runs: 1, metrics: [:process_time], formats: [:call_tree] }
  
  SIZE = 6
  
  def setup
    @api_key = FactoryBot.create(:api_application).key
    @purpose = create(:plate_purpose, target_type: 'Plate', name: 'Stock Plate', size: '96')
  end
  
  def create_plate
    user = create :user
    parent_plate = create :plate
    purpose_to_create = create :plate_purpose 

    params_for_plate_creation = {
      "user": user.uuid,      
      "parent": parent_plate.uuid,
      "child_purpose": purpose_to_create.uuid
    }
  
    post '/api/1/plate_creations', 
      params: { plate_creation: params_for_plate_creation }, 
      headers: { content_type: 'application/json', accept: 'application/json', 'HTTP_X_SEQUENCESCAPE_CLIENT_ID' => @api_key }, 
      as: :json
  end

  # test 'PlatePurpose.create' do
  #   ActiveRecord::Base.transaction do
  #     @purpose.create!(barcode: '12345')
  #   end
  # end

  test 'POST plate creation' do
    print "*****************"
    print ENV["RAILS_ENV"]
    1.times do |i|
      create_plate
    end
  end
end

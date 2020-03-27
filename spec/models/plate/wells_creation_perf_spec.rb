# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'WellsCreationPerformance' do
  include BarcodeHelper
  
  let(:plate_purpose) { 
    create(:plate_purpose, target_type: 'Plate', name: 'Stock Plate', size: '96')
  }
  
  before do
    mock_plate_barcode_service
  end

  context 'when we create a new plate' do
    xit 'runs the wells creation in multiple SQL queries' do
      start_time = DateTime.now
      100.times do |i|
        plate_purpose._create_without_import!
      end
      end_time = DateTime.now
      print "Time taken: " + (end_time.to_i - start_time.to_i).to_s
    end
    
    it 'runs the wells creation in a single SQL' do
      start_time = DateTime.now
      100.times do |i|
        plate_purpose._create_with_import!
      end
      end_time = DateTime.now
      print "Time taken: " + (end_time.to_i - start_time.to_i).to_s
    end
  end
end
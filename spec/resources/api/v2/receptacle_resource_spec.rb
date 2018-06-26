require 'rails_helper'
require './app/resources/api/v2/receptacle_resource'

RSpec.describe Api::V2::ReceptacleResource, type: :resource do
  let(:resource_model) { create :receptacle }
  subject(:resource) { described_class.new(resource_model, {}) }

  # Test attributes
  it 'works', :aggregate_failures do
    is_expected.to have_attribute :uuid
    is_expected.to have_attribute :name
    is_expected.to_not have_updatable_field(:id)
    is_expected.to_not have_updatable_field(:uuid)
    is_expected.to_not have_updatable_field(:name)
    is_expected.to have_many(:samples).with_class_name('Sample')
    is_expected.to have_many(:projects).with_class_name('Project')
    is_expected.to have_many(:studies).with_class_name('Study')
  end

  # Custom method tests
  # Add tests for any custom methods you've added.
  # describe '#labware_barcode' do
  #   subject { resource.labware_barcode }
  #   it { is_expected.to eq('ean13_barcode' => '', 'human_barcode' => '') }
  # end
end

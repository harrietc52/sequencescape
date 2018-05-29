# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QcResult, type: :model, qc_result: true do
  it 'is not valid without a key' do
    expect(build(:qc_result, key: nil)).to_not be_valid
  end

  it 'is not valid without a value' do
    expect(build(:qc_result, value: nil)).to_not be_valid
  end

  it 'is not valid without units' do
    expect(build(:qc_result, units: nil)).to_not be_valid
  end

  it 'must have an asset' do
    expect(build(:qc_result, asset: nil)).to_not be_valid
  end

  it 'can have a cv' do
    expect(build(:qc_result).cv).to be_present
  end

  it 'can have an assay type' do
    expect(build(:qc_result).assay_type).to be_present
  end

  it 'can have an assay version' do
    expect(build(:qc_result).assay_version).to be_present
  end

  context 'with an asset' do
    let(:asset) { build :asset }

    it 'can update its asset' do
      expect(asset).to receive(:update_from_qc).with(an_instance_of(QcResult))
      create :qc_result, asset: asset
    end
  end
end

describe QcResult, warren: true do
  let(:warren) { Warren.handler }

  setup { warren.clear_messages }
  let(:resource) { build :qc_result }
  let(:routing_key) { 'test.message.qc_result.' }

  it 'broadcasts the resource' do
    resource.save!
    expect(warren.messages_matching(routing_key)).to eq(1)
  end
end

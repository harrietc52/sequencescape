# frozen_string_literal: true

# This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2018 Genome Research Ltd.

require 'rails_helper'

RSpec.describe TagGroup, type: :model do
  context 'when the name is not unique' do
    let(:tag_group_1) { create(:tag_group, tag_count: 3, name: 'test name') }
    let(:tag_group_2) { build(:tag_group, tag_count: 3, name: 'test name') }

    it 'is not a valid model' do
      tag_group_1
      expect(tag_group_2.valid?).to be_falsey
    end
  end

  context 'when the tags are sorted' do
    let(:tag_group_1) { create(:tag_group) }
    let(:tag_1) { create(:tag, map_id: 1, tag_group: tag_group_1) }
    let(:tag_2) { create(:tag, map_id: 4, tag_group: tag_group_1) }
    let(:tag_3) { create(:tag, map_id: 2, tag_group: tag_group_1) }
    let(:tag_4) { create(:tag, map_id: 3, tag_group: tag_group_1) }

    context 'by map id' do
      it 'should return the tags in the correct order' do
        tag_group_1.tags << tag_1 << tag_2 << tag_3 << tag_4
        expect(tag_group_1.tags_sorted_by_map_id).to eq([tag_1, tag_3, tag_4, tag_2])
      end
    end

    context 'by index' do
      it 'should return the tags in the correct order' do
        tag_group_1.tags << tag_1 << tag_2 << tag_3 << tag_4
        expect(tag_group_1.indexed_tags).to eq(1 => tag_1.oligo, 2 => tag_3.oligo, 3 => tag_4.oligo, 4 => tag_2.oligo)
      end
    end
  end

  context 'when the tag group is not visible' do
    let!(:tag_group_1) { create(:tag_group_with_tags, name: 'TG1') }
    let!(:tag_group_2) { create(:tag_group_with_tags, name: 'TG2', visible: false) }
    let!(:tag_group_3) { create(:tag_group_with_tags, name: 'TG3') }

    it 'should not be selectable by the visible scope' do
      expect(TagGroup.visible).to_not include(tag_group_2)
    end

    it 'remaining tag groups should be selectable by the visible scope' do
      expect(TagGroup.visible).to include(tag_group_1, tag_group_3)
    end
  end
end

# frozen_string_literal: true

# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2018 Genome Research Ltd.

##
# This form object class handles the user interaction for creating new Tag Groups.
# It sensibility checks the user-entered list of Tag oligo sequences before creating
# the Tag Group and Tags.
class TagGroup::FormObject
  include ActiveModel::Model

  # Attributes
  attr_accessor :name, :oligos_text

  # Access the tag group record after it's saved
  attr_reader :tag_group

  # Validations
  validates :oligos_text, presence: true
  validates :name, presence: true
  validate :check_entered_oligos

  def save
    if valid?
      persist!
      true
    else
      errors.add(:oligos_text, I18n.t('tag_groups.errors.tag_group_form_invalid'))
      false
    end
  end

  # form builder methods (e.g. form_to) need the Active Model name to be set
  def self.model_name
    ActiveModel::Name.new(TagGroup)
  end

  private

  def parse_oligos_list
    oligos_text&.squish&.split(/[\s\,]+/) || []
  end

  def check_entered_oligos
    invalid_oligos_list = []
    valid_oligos_hash = {}
    parse_oligos_list.each do |cur_oligo|
      if cur_oligo.match?(/^[ACGTacgt]*$/)
        if valid_oligos_hash.key?(cur_oligo)
          errors.add(:base, I18n.t('tag_groups.errors.duplicate_oligo_found') + cur_oligo)
        else
          valid_oligos_hash[cur_oligo] = 1
        end
      else
        invalid_oligos_list << cur_oligo
      end
    end
    errors.add(:base, I18n.t('tag_groups.errors.invalid_oligos_found') + invalid_oligos_list.join(',')) unless invalid_oligos_list.size.zero?
    errors.add(:base, I18n.t('tag_groups.errors.no_valid_oligos_found')) if valid_oligos_hash.empty?
  end

  def persist!
    TagGroup.transaction do
      @tag_group = TagGroup.new(name: name)
      @tag_group.tags.build(parse_oligos_list.each_with_index.map { |oligo, i| { oligo: oligo.upcase, map_id: i + 1 } })
      return if @tag_group.save

      errors.add(:base, I18n.t('tag_groups.errors.failed_to_save_tag_group'))
      @tag_group.errors.full_messages.each do |msg|
        errors.add_to_base("TagGroup Error: #{msg}")
      end
    end
  end
end

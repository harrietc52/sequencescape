# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2013,2015 Genome Research Ltd.

class LabEvent < ActiveRecord::Base
  belongs_to :batch
  belongs_to :user
  belongs_to :eventful, polymorphic: true
  acts_as_descriptable :serialized

  before_validation :unescape_for_descriptors

  scope :with_descriptor, ->(k, v) { where(['descriptors LIKE ?', "%#{k}: #{v}%"]) }

  scope :barcode_code, ->(*args) { where(["(description = 'Cluster generation' or description = 'Add flowcell chip barcode') and eventful_type = 'Request' and descriptors like ? ", args[0]]) }

  def unescape_for_descriptors
    self[:descriptors] = (self[:descriptors] || {}).each_with_object({}) do |(key, value), hash|
      hash[CGI.unescape(key)] = value
    end
  end

  def self.find_by_barcode(barcode)
    batch_id = 0

    search = "%Chip Barcode: #{barcode}%"
    requests = barcode_code(search)
    batch = requests.map(&:batch_id).uniq
    batch_id = batch[0] unless batch.size != 1

    batch_id
  end

  def descriptor_value_for(name)
    descriptors.each do |desc|
      if desc.name.casecmp(name.to_s).zero?
        return desc.value
      end
    end
    nil
  end

  def add_new_descriptor(name, value)
    add_descriptor Descriptor.new(name: name, value: value)
  end
end

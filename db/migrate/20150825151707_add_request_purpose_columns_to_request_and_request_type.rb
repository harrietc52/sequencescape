# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2015 Genome Research Ltd.

class AddRequestPurposeColumnsToRequestAndRequestType < ActiveRecord::Migration
  def self.up
    add_column :request_types, :request_purpose_id, :integer
    add_column :requests, :request_purpose_id, :integer
  end

  def self.down
    remove_column :request_types, :request_purpose_id
    remove_column :requests, :request_purpose_id
  end
end

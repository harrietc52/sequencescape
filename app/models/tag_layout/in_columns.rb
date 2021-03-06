# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011,2012,2015 Genome Research Ltd.

# Lays out the tags so that they are column ordered.
module TagLayout::InColumns
  def self.direction
    'column'
  end

  def self.well_order_scope
    :in_column_major_order
  end
end

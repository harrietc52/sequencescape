# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2012,2015 Genome Research Ltd.

class Io::Lane < Io::Asset
  set_model_for_input(::Lane)
  set_json_root(:lane)
  define_attribute_and_json_mapping("
           external_release  => external_release
  ")
end

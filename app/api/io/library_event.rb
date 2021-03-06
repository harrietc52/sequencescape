# This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2016 Genome Research Ltd.
class Io::LibraryEvent < ::Core::Io::Base
  set_model_for_input(::LibraryEvent)
  set_json_root(:library_event)

  define_attribute_and_json_mapping("
              event_type <=> event_type
                    user <=> user
                    seed <=> seed
  ")
end

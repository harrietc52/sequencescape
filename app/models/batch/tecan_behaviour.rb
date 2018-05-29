# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2012,2013,2015 Genome Research Ltd.

module Batch::TecanBehaviour
  def generate_tecan_data(target_barcode, override_plate_type = nil)
    data_object = {
      'user' => user.login,
      'time' => Time.now,
      'source' => {},
      'destination' => {}
    }

    requests.includes([{ asset: :plate }, { target_asset: :plate }]).where(state: 'passed').find_each do |request|
      target_plate = request.target_asset.plate
      next unless [target_plate.human_barcode, target_plate.machine_barcode].include?(target_barcode)

      full_source_barcode = request.asset.plate.barcode_for_tecan
      full_destination_barcode = request.target_asset.plate.barcode_for_tecan

      source_plate_name = override_plate_type.presence || request.asset.plate.stock_plate_name.tr('_', "\s")

      if data_object['source'][full_source_barcode].nil?
        data_object['source'][full_source_barcode] = { 'name' => source_plate_name, 'plate_size' => request.asset.plate.size }
      end
      if data_object['destination'][full_destination_barcode].nil?
        data_object['destination'][full_destination_barcode] = {
          'name' => PlateType.cherrypickable_default_type.tr('_', "\s"),
          'plate_size' => request.target_asset.plate.size
        }
      end
      if data_object['destination'][full_destination_barcode]['mapping'].nil?
        data_object['destination'][full_destination_barcode]['mapping'] = []
      end

      data_object['destination'][full_destination_barcode]['mapping'] << {
        'src_well'  => [full_source_barcode, request.asset.map.description],
        'dst_well'  => request.target_asset.map.description,
        'volume'    => (request.target_asset.get_picked_volume),
        'buffer_volume' => (request.target_asset.get_buffer_volume)
      }
    end

    data_object
  end

  def tecan_layout_plate_barcodes(target_barcode)
    data_object = generate_tecan_data(target_barcode)
    dest_barcode_index = Sanger::Robots::Tecan::Generator.barcode_to_plate_index(data_object['destination'])
    source_barcode_index = Sanger::Robots::Tecan::Generator.source_barcode_to_plate_index(data_object['destination'])
    [dest_barcode_index, source_barcode_index]
  end

  def tecan_gwl_file_as_text(target_barcode, volume_required = 13, plate_type = nil)
    data_object = generate_tecan_data(target_barcode, plate_type)
    Sanger::Robots::Tecan::Generator.mapping(data_object, volume_required.to_i)
  end
end

# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2012,2013,2015,2016 Genome Research Ltd.

module Tasks::PlateTemplateHandler
  # Class to extract the layout from an uploaded spreadsheet
  class SpreadsheetReader
    def initialize(csv_string, batch, plate_size)
      @csv_string = csv_string
      @batch = batch
      @plate_size = plate_size
    end

    def layout
      barcodes = Set.new
      plates = mapped_plate_wells.map do |_plate_key, mapped_wells|
        (0...plate_size).map do |i|
          well, location, request_id = CherrypickTask::EMPTY_WELL, *mapped_wells[i]
          if request_id.present?
            asset = batch.requests.find(request_id).asset
            barcodes << asset.plate.barcode_number
            well = [request_id, asset.plate.barcode_number, asset.display_name]
          end
          well
        end
      end

      [plates, barcodes.to_a]
    end

    private

    def mapped_plate_wells
      (Hash.new { |h, k| h[k] = {} }).tap do |parsed_plates|
        CSV.parse(csv_string, headers: :first_row) do |row|
          parse_spreadsheet_row(row['Request ID'], row['Sample Name'], row['Plate'], row['Destination Well']) do |plate_key, request_id, location|
            parsed_plates[plate_key][location.column_order] = [location, request_id]
          end
        end
      end
    end

    def parse_spreadsheet_row(request_id, _asset_name, plate_key, destination_well)
      return if request_id.blank? or request_id.to_i == 0
      return if destination_well.blank? or destination_well.to_i > 0

      location = Map.find_by(description: destination_well, asset_size: plate_size) or return
      plate_key = 'default plate 1' if plate_key.blank?
      yield(plate_key, request_id.to_i, location)
    end

    attr_reader :batch, :plate_size, :csv_string
  end

  def render_plate_template_task(task, _params)
    @robots = Robot.all
    set_plate_purpose_options(task)
    suitable_sizes = @plate_purpose_options.map { |o| o[1] }.uniq
    @plate_templates = PlateTemplate.with_sizes(suitable_sizes)
  end

  def set_plate_purpose_options(task)
    @plate_purpose_options = task.plate_purpose_options(@batch)
  end

  def do_plate_template_task(_task, params)
    return true if params[:file].blank?

    plate_size = if params[:plate_template].blank?
                   PlatePurpose.find(params[:plate_purpose_id]).size
                 else
                   PlateTemplate.find(params[:plate_template]['0'].to_i).size
                 end
    # parsed_plate_details = parse_uploaded_spreadsheet_layout(params[:file].read, plate_size)
    # @spreadsheet_layout = map_parsed_spreadsheet_to_plate(parsed_plate_details, @batch, plate_size)
    @spreadsheet_layout = SpreadsheetReader.new(params[:file].read, @batch, plate_size).layout
    true
  end

  def self.generate_spreadsheet(batch)
    CSV.generate(row_sep: "\r\n") do |csv|
      csv << ['Request ID', 'Sample Name', 'Plate', 'Destination Well']
      batch.requests.each { |r| csv << [r.id, r.asset.sample.name, '', ''] }
    end
  end
end

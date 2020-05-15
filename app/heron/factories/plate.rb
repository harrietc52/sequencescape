# frozen_string_literal: true

module Heron
  module Factories
    # Factory class to create Heron tube racks
    class Plate
      include ActiveModel::Model
      include Concerns::ForeignBarcodes
      include Concerns::CoordinatesSupport

      attr_accessor :plate

      validate :plate_purpose_exists

      validate :validate_wells_content

      def initialize(params)
        @params = params
      end

      def barcode
        @params[:barcode]
      end

      def wells_content
        @wells_content ||= ::Heron::Factories::Content.new(@params[:wells_content], @params[:study_uuid])
      end

      def validate_wells_content
        return if wells_content.valid?

        errors.add(:wells_content, wells_content.errors.full_messages)
      end

      def plate_purpose_exists
        unless @params.key?(:plate_purpose_uuid)
          errors.add(:base, 'Plate purpose uuid not defined')
          return
        end
        @plate_purpose ||= PlatePurpose.with_uuid(@params[:plate_purpose_uuid]).first
        errors.add(:base, "Plate purpose for uuid (#{@params[:plate_purpose_uuid]}) do not exist") unless @plate_purpose
      end

      attr_reader :plate_purpose


      def create_containers!
        @plate = plate_purpose.create!

        Barcode.create!(asset: @plate, barcode: barcode, format: barcode_format)
      end

      def containers_for_locations
        @plate.wells.reduce({}) do |memo, well|
          memo[unpad_coordinate(well.map.description)] = well
          memo
        end
      end

      def create_contents!
        wells_content.add_aliquots_into_locations(containers_for_locations)
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          create_containers!
          create_contents!
        end
        true
      end
    end
  end
end

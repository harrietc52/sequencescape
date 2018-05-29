# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2012,2013,2014,2015 Genome Research Ltd.

require 'test_helper'

class PlateTest < ActiveSupport::TestCase
  def create_plate_with_fluidigm(fluidigm_barcode)
    barcode = '1234567'
    purpose = create :plate_purpose
    purpose.create!(:do_not_create_wells, name: "Cherrypicked #{barcode}", size: 192, barcode: barcode, fluidigm_barcode: fluidigm_barcode)
  end

  context '' do
    context '#infinium_barcode=' do
      setup do
        @plate = Plate.new
        @plate.infinium_barcode = 'AAA'
      end

      should 'set the infinium barcode' do
        assert_equal 'AAA', @plate.infinium_barcode
      end
    end

    context '#fluidigm_barcode' do
      should 'check that I cannot create a plate with a fluidigm barcode different from 10 characters' do
        assert_raises(ActiveRecord::RecordInvalid) { create_plate_with_fluidigm('12345678') }
      end
      should 'check that I can create a plate with a fluidigm barcode equal to 10 characters' do
        assert_nothing_raised { create_plate_with_fluidigm('1234567890') }
      end
    end

    context '#add_well' do
      [[96, 7, 11], [384, 15, 23]].each do |plate_size, row_size, col_size|
        context "for #{plate_size} plate" do
          setup do
            @well = Well.new
            @plate = Plate.new(name: 'Test Plate', size: plate_size, purpose: Purpose.find_by(name: 'Stock Plate'))
          end
          context 'with valid row and col combinations' do
            (0..row_size).step(1) do |row|
              (0..col_size).step(1) do |col|
                should "not return nil: row=> #{row}, col=>#{col}" do
                  assert @plate.add_well(@well, row, col)
                end
              end
            end
          end
        end
      end
    end

    context '#sample?' do
      setup do
        @plate = create :plate
        @sample = create :sample, name: 'abc'
        @well_asset = Well.create!.tap { |well| well.aliquots.create!(sample: @sample) }
        @plate.add_and_save_well @well_asset
      end
      should 'find the sample name if its valid' do
        assert Plate.find(@plate.id).sample?('abc')
      end
      should 'not find the sample name if its invalid' do
        assert_equal false, Plate.find(@plate.id).sample?('abcdef')
      end
    end
  end

  context '#iteration' do
    setup do
      @parent = create :plate, created_at: 6.hours.ago
      tested_purpose = create :plate_purpose
      @parent.children << @child_a = create(:plate, plate_purpose: tested_purpose, created_at: 5.hours.ago)
      @parent.children << @child_b = create(:plate, plate_purpose: tested_purpose, created_at: 4.hours.ago)
      @child_b.children << @dummy = create(:plate, plate_purpose: tested_purpose, created_at: 3.hours.ago)
      @parent.children << @child_c = create(:plate, plate_purpose: tested_purpose, created_at: 1.hour.ago)
      @parent.children << @child_d = create(:plate)
    end

    should 'correctly calculate iterations' do
      assert_equal 1, @child_a.reload.iteration, 'First child is not iteration 1'
      assert_equal 2, @child_b.reload.iteration, 'Second child is not iteration 2'
      assert_equal 3, @child_c.reload.iteration, 'Third child created after grandchild is not iteration 3'
      assert_equal 1, @child_d.reload.iteration, 'First child of another purpose is not iteration 1'
    end
  end

  context '#plate_ids_from_requests' do
    setup do
      @well1 = Well.new
      @plate1 = create :plate
      @plate1.add_and_save_well(@well1)
      @request1 = create :well_request, asset: @well1
    end

    context 'with 1 request' do
      context 'with a valid well asset' do
        should 'return correct plate ids' do
          assert Plate.plate_ids_from_requests([@request1]).include?(@plate1.id)
        end
      end
    end

    context 'with 2 requests on the same plate' do
      setup do
        @well2 = Well.new
        @plate1.add_and_save_well(@well2)
        @request2 = create :well_request, asset: @well2
      end
      context 'with a valid well assets' do
        should 'return a single plate ID' do
          assert Plate.plate_ids_from_requests([@request1, @request2]).include?(@plate1.id)
          assert Plate.plate_ids_from_requests([@request2, @request1]).include?(@plate1.id)
        end
      end
    end

    context 'with multiple requests on different plates' do
      setup do
        @well2 = Well.new
        @plate2 = create :plate
        @plate2.add_and_save_well(@well2)
        @request2 = create :well_request, asset: @well2
        @well3 = Well.new
        @plate1.add_and_save_well(@well3)
        @request3 = create :well_request, asset: @well3
      end
      context 'with a valid well assets' do
        should 'return 2 plate IDs' do
          assert Plate.plate_ids_from_requests([@request1, @request2, @request3]).include?(@plate1.id)
          assert Plate.plate_ids_from_requests([@request1, @request2, @request3]).include?(@plate2.id)
          assert Plate.plate_ids_from_requests([@request3, @request1, @request2]).include?(@plate1.id)
          assert Plate.plate_ids_from_requests([@request3, @request1, @request2]).include?(@plate2.id)
        end
      end
    end
  end

  context 'Plate priority' do
    setup do
      @plate = create :transfer_plate
      user = create(:user)
      @plate.wells.each_with_index do |well, index|
        create :request, asset: well, submission: Submission.create!(priority: index + 1, user: user)
      end
    end

    should 'inherit the highest submission priority' do
      assert_equal 3, @plate.priority
    end
  end

  context 'A Plate' do
    setup do
      @plate = Plate.create!
    end

    context 'without attachments' do
      should 'not report any qc_data' do
        assert @plate.qc_files.empty?
      end
    end

    context 'with attached qc data' do
      setup do
        File.open('test/data/manifests/mismatched_plate.csv') do |file|
          @plate.add_qc_file file
        end
      end

      should 'return any qc data' do
        assert @plate.qc_files.count == 1
        File.open('test/data/manifests/mismatched_plate.csv') do |file|
          assert_equal file.read, @plate.qc_files.first.uploaded_data.file.read
        end
      end
    end

    context 'with multiple attached qc data' do
      setup do
        File.open('test/data/manifests/mismatched_plate.csv') do |file|
          @plate.add_qc_file file
          @plate.add_qc_file file
        end
      end

      should 'return multiple qc data' do
        assert @plate.qc_files.count == 2
      end
    end
  end

  context 'with existing well data' do
    class MockParser
      def each_well_and_parameters
        yield('B1', { set_concentration: '2', set_molarity: '3' })
        yield('C1', { set_concentration: '4', set_molarity: '5' })
      end
    end

    setup do
      @plate = create :plate_with_empty_wells, well_count: 3
      # @plate.wells.build([
      #   { map: Map.find_by(description: 'A1') },
      #   { map: Map.find_by(description: 'B1') },
      #   { map: Map.find_by(description: 'C1') }
      #   ])
      @plate.wells.first.set_concentration('12')
      @plate.wells.first.set_molarity('34')
      # @plate.save! # Because we use a well scope, and mocking it is asking for trouble

      @plate.update_qc_values_with_parser(MockParser.new)
    end

    should 'update new wells' do
      well_b1 = @plate.wells.detect { |w| w.map_description == 'B1' }.reload
      well_c1 = @plate.wells.detect { |w| w.map_description == 'C1' }.reload

      assert_equal 2.0, well_b1.get_concentration
      assert_equal 3.0, well_b1.get_molarity
      assert_equal 4.0, well_c1.get_concentration
      assert_equal 5.0, well_c1.get_molarity
    end

    should 'not clear existing data' do
      well_a1 = @plate.wells.detect { |w| w.map_description == 'A1' }.reload
      assert_equal 12.0, well_a1.get_concentration
      assert_equal 34.0, well_a1.get_molarity
    end
  end

  context '::with_descendants_owned_by' do
    setup do
      @user = create :user
      @source_plate = create :source_plate
      @child_plate = create :child_plate, parent: @source_plate
    end

    should 'find source plates with owners' do
      create :plate_owner, user: @user, plate: @child_plate
      assert_includes Plate.with_descendants_owned_by(@user), @source_plate
    end

    should 'not find plates without owners' do
      refute_includes Plate.with_descendants_owned_by(@user), @source_plate
    end

    should 'allow filtering of source plates' do
      plates = Plate.source_plates
      assert_includes plates, @source_plate
      refute_includes plates, @child_plate
    end
  end

  context 'tubes are created from plate' do
    should 'send print request' do
      plate = create :plate
      10.times { plate.add_and_save_well(create :well_with_sample_and_without_plate) }
      barcode_printer = create :barcode_printer
      LabelPrinter::PmbClient.stubs(:get_label_template_by_name).returns('data' => [{ 'id' => 15 }])

      RestClient.expects(:post)

      plate.create_sample_tubes_and_print_barcodes(barcode_printer)
    end
  end
end

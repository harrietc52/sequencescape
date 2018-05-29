# frozen_string_literal: true

FactoryGirl.define do
  sequence(:barcode_number) { |i| i }

  factory :barcode, aliases: [:external] do
    association(:asset, factory: :asset)
    sequence(:barcode) { |i| "EXT_#{i}_A" }
    format 'external'

    factory :sanger_ean13 do
      transient do
        prefix 'DN'
        barcode_number
      end
      format 'sanger_ean13'
      barcode { SBCF::SangerBarcode.new(prefix: prefix, number: barcode_number).human_barcode }

      factory :sanger_ean13_tube do
        transient do
          prefix 'NT'
        end
      end
    end

    factory :infinium do
      transient do
        prefix 'WG'
        suffix 'DNA'
        sequence(:number) { |i| i.to_s.rjust(7, '0') }
      end
      format 'infinium'
      barcode { "#{prefix}#{number}-#{suffix}" }
    end

    factory :fluidigm do
      transient do
        sequence(:number) { |i| '1' + i.to_s.rjust(9, '0') }
      end
      format 'fluidigm'
      barcode { number }
    end
  end
end


require "#{Rails.root}/app/models/illumina_b/plate_purposes"

class Search::FindIlluminaBStockPlates < Search::FindIlluminaBPlates
  def illumina_b_plate_purposes
    PlatePurpose.where(name: [IlluminaB::PlatePurposes::STOCK_PLATE_PURPOSE, IlluminaHtp::PlatePurposes::STOCK_PLATE_PURPOSE].concat(Pulldown::PlatePurposes::STOCK_PLATE_PURPOSES))
  end
  private :illumina_b_plate_purposes
end

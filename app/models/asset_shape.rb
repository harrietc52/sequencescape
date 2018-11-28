class AssetShape < ApplicationRecord
  include SharedBehaviour::Named

  validates_presence_of :name, :horizontal_ratio, :vertical_ratio, :description_strategy
  validates_numericality_of :horizontal_ratio, :vertical_ratio

  def self.default_id
    @default_id ||= default.id
  end

  def self.default
    AssetShape.find_by(name: 'Standard')
  end

  def standard?
    horizontal_ratio == 3 && vertical_ratio == 2
  end

  def plate_height(size)
    multiplier(size) * vertical_ratio
  end

  def plate_width(size)
    multiplier(size) * horizontal_ratio
  end

  def horizontal_to_vertical(well_position, plate_size)
    alternate_position(well_position, plate_size, :width, :height)
  end

  def vertical_to_horizontal(well_position, plate_size)
    alternate_position(well_position, plate_size, :height, :width)
  end

  def interlaced_vertical_to_horizontal(well_position, plate_size)
    alternate_position(interlace(well_position, plate_size), plate_size, :height, :width)
  end

  def vertical_to_interlaced_vertical(well_position, plate_size)
    interlace(well_position, plate_size)
  end

  def generate_map(size)
    raise StandardError, 'Map already exists' if Map.find_by(asset_size: size, asset_shape_id: id).present?

    ActiveRecord::Base.transaction do
      map_data = Array.new(size) do |i|
        {
          asset_size: size,
          asset_shape_id: id,
          location_id: i + 1,
          row_order: i,
          column_order: (horizontal_to_vertical(i + 1, size) || 1) - 1,
          description: location_from_index(i, size)
        }
      end
      Map.import(map_data)
    end
  end

  def alternate_position(well_position, size, *dimensions)
    return nil unless Map.valid_well_position?(well_position)

    divisor, multiplier = dimensions.map { |n| send("plate_#{n}", size) }
    column, row = (well_position - 1).divmod(divisor)
    return nil unless (0...multiplier).cover?(column)
    return nil unless (0...divisor).cover?(row)

    alternate = (row * multiplier) + column + 1
  end

  def location_from_row_and_column(row, column, size = 96)
    description_strategy.constantize.location_from_row_and_column(row, column, plate_width(size), size)
  end

  private

  def multiplier(size)
    ((size / (vertical_ratio * horizontal_ratio))**0.5).to_i
  end

  def interlace(i, size)
    m, d = (i - 1).divmod(size / 2)
    2 * d + 1 + m
  end

  def location_from_index(index, size = 96)
    description_strategy.constantize.location_from_index(index, size)
  end
end

# Lays out the tags so that they are column ordered.
module TagLayout::InColumns
  def self.direction
    'column'
  end

  def self.well_order_scope
    :in_column_major_order
  end

  # Returns the tag index for the primary tag
  # That is the one laid out in columns with four copies of each
  def self.quad_tag_index(row, column, scale, height, _width)
    tag_col = (column / scale)
    tag_row = (row / scale)
    tag_row + (height / scale * tag_col)
  end

  def self.quad_tag2_index(row, column, scale, height, width)
    quad_tag_index(row, column, scale, height, width)
  end

  def self.comb_tag_index(_row, column, _scale, _height, _width)
    column
  end

  def self.comb_tag2_index(row, _column, _scale, _height, _width)
    row
  end
end

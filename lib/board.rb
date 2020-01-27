class ChessBoard
  def initialize(white_pieces, black_pieces)
  end

  def self.location_to_coordinates(location)
    column = location.codepoints[0] - 97
    row = location[1].to_i - 1
    [column, row]
  end
end
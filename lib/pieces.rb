# frozen_string_literal: true

# Base class for all chess pieces.
class ChessPiece
  attr_reader :starting_location, :owner

  def initialize(glyph, starting_location, owner)
    @glyph = glyph
    @starting_location = starting_location
    @owner = owner
  end

  def to_s
    @glyph
  end
end

# A pawn in a game of chess.
class Pawn < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

# A rook in a game of chess.
class Rook < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

# A knight in a game of chess.
class Knight < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

# A bishop in a game of chess.
class Bishop < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

# A queen in a game of chess.
class Queen < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

# A king in a game of chess.
class King < ChessPiece
  def initialize(glyph, starting_location, owner)
    super
  end
end

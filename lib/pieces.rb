# frozen_string_literal: true

# Module with convenience method to obtain
# two sets of pieces ready for a new game.
module InitialPieces
  def self.pieces_for_new_game(white_name = 'white', black_name = 'black')
    white_pieces = [
      Pawn.new('♙', 'a2', white_name),
      Pawn.new('♙', 'b2', white_name),
      Pawn.new('♙', 'c2', white_name),
      Pawn.new('♙', 'd2', white_name),
      Pawn.new('♙', 'e2', white_name),
      Pawn.new('♙', 'f2', white_name),
      Pawn.new('♙', 'g2', white_name),
      Pawn.new('♙', 'h2', white_name),
      Rook.new('♖', 'a1', white_name),
      Rook.new('♖', 'h1', white_name),
      Knight.new('♘', 'b1', white_name),
      Knight.new('♘', 'g1', white_name),
      Bishop.new('♗', 'c1', white_name),
      Bishop.new('♗', 'f1', white_name),
      Queen.new('♕', 'd1', white_name),
      King.new('♔', 'e1', white_name)
    ]
    black_pieces = [
      Pawn.new('♟', 'a7', black_name),
      Pawn.new('♟', 'b7', black_name),
      Pawn.new('♟', 'c7', black_name),
      Pawn.new('♟', 'd7', black_name),
      Pawn.new('♟', 'e7', black_name),
      Pawn.new('♟', 'f7', black_name),
      Pawn.new('♟', 'g7', black_name),
      Pawn.new('♟', 'h7', black_name),
      Rook.new('♜', 'a8', black_name),
      Rook.new('♜', 'h8', black_name),
      Knight.new('♞', 'b8', black_name),
      Knight.new('♞', 'g8', black_name),
      Bishop.new('♝', 'c8', black_name),
      Bishop.new('♝', 'f8', black_name),
      Queen.new('♛', 'd8', black_name),
      King.new('♚', 'e8', black_name)
    ]
    [white_pieces, black_pieces]
  end
end

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

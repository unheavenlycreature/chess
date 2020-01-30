# frozen_string_literal: true

# Module with convenience method to obtain
# two sets of pieces ready for a new game.
module InitialPieces
  def self.pieces_for_new_game(white_color, blue_color, white_name = 'white', blue_name = 'blue')
    white_pieces = [
      Pawn.new('a2', white_color, white_name),
      Pawn.new('b2', white_color, white_name),
      Pawn.new('c2', white_color, white_name),
      Pawn.new('d2', white_color, white_name),
      Pawn.new('e2', white_color, white_name),
      Pawn.new('f2', white_color, white_name),
      Pawn.new('g2', white_color, white_name),
      Pawn.new('h2', white_color, white_name),
      Rook.new('a1', white_color, white_name),
      Rook.new('h1', white_color, white_name),
      Knight.new('b1', white_color, white_name),
      Knight.new('g1', white_color, white_name),
      Bishop.new('c1', white_color, white_name),
      Bishop.new('f1', white_color, white_name),
      Queen.new('d1', white_color, white_name),
      King.new('e1', white_color, white_name)
    ]
    blue_pieces = [
      Pawn.new('a7', blue_color, blue_name),
      Pawn.new('b7', blue_color, blue_name),
      Pawn.new('c7', blue_color, blue_name),
      Pawn.new('d7', blue_color, blue_name),
      Pawn.new('e7', blue_color, blue_name),
      Pawn.new('f7', blue_color, blue_name),
      Pawn.new('g7', blue_color, blue_name),
      Pawn.new('h7', blue_color, blue_name),
      Rook.new('a8', blue_color, blue_name),
      Rook.new('h8', blue_color, blue_name),
      Knight.new('b8', blue_color, blue_name),
      Knight.new('g8', blue_color, blue_name),
      Bishop.new('c8', blue_color, blue_name),
      Bishop.new('f8', blue_color, blue_name),
      Queen.new('d8', blue_color, blue_name),
      King.new('e8', blue_color, blue_name)
    ]
    [white_pieces, blue_pieces]
  end
end

# Base class for all chess pieces.
class ChessPiece
  attr_accessor :current_position
  attr_reader :owner, :starting_position, :allowed_moves

  def initialize(glyph, starting_position, color, owner, allowed_moves)
    @glyph = glyph
    @starting_position = starting_position
    @current_position = starting_position
    @color = color
    @owner = owner
    @allowed_moves = allowed_moves
  end

  def to_s
    @glyph.colorize(@color)
  end
end

# A pawn in a game of chess.
class Pawn < ChessPiece
  attr_writer :allowed_moves
  def initialize(starting_position, color, owner)
    super('♟', starting_position, color, owner, \
      %i[two_spaces_forward one_space_forward diagonal_to_take])
  end
end

# A rook in a game of chess.
class Rook < ChessPiece
  attr_writer :allowed_moves
  def initialize(starting_position, color, owner)
    super('♜', starting_position, color, owner, %i[horizontal vertical castling])
  end
end

# A knight in a game of chess.
class Knight < ChessPiece
  def initialize(starting_position, color, owner)
    super('♞', starting_position, color, owner, %i[knight])
  end
end

# A bishop in a game of chess.
class Bishop < ChessPiece
  def initialize(starting_position, color, owner)
    super('♝', starting_position, color, owner, %i[diagonal])
  end
end

# A queen in a game of chess.
class Queen < ChessPiece
  def initialize(starting_position, color, owner)
    super('♛', starting_position, color,owner, %i[horizontal vertical diagonal])
  end
end

# A king in a game of chess.
class King < ChessPiece
  attr_writer :allowed_moves
  def initialize(starting_position, color, owner)
    super('♚', starting_position, color, owner, %i[one_any_direction castling])
  end
end

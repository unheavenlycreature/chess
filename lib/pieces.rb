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
  attr_accessor :current_position
  attr_reader :owner, :starting_position, :allowed_moves

  def initialize(glyph, starting_position, owner, allowed_moves)
    @glyph = glyph
    @starting_position = starting_position
    @current_position = starting_position
    @owner = owner
    @allowed_moves = allowed_moves
  end

  def to_s
    @glyph
  end
end

# A pawn in a game of chess.
class Pawn < ChessPiece
  attr_writer :allowed_moves
  def initialize(glyph, starting_position, owner)
    super(glyph, starting_position, owner, \
      %i[two_spaces_forward one_space_forward diagonal_to_take])
  end
end

# A rook in a game of chess.
class Rook < ChessPiece
  attr_writer :allowed_moves
  def initialize(glyph, starting_position, owner)
   super(glyph, starting_position, owner, %i[horizontal vertical castling])
  end
end

# A knight in a game of chess.
class Knight < ChessPiece
  def initialize(glyph, starting_position, owner)
    super(glyph, starting_position, owner, %i[knight])
  end
end

# A bishop in a game of chess.
class Bishop < ChessPiece
  def initialize(glyph, starting_position, owner)
    super(glyph, starting_position, owner, %i[diagonal])
  end
end

# A queen in a game of chess.
class Queen < ChessPiece
  def initialize(glyph, starting_position, owner)
    super(glyph, starting_position, owner, %i[horizontal vertical diagonal])
  end
end

# A king in a game of chess.
class King < ChessPiece
  attr_writer :allowed_moves
  def initialize(glyph, starting_position, owner)
    super(glyph, starting_position, owner, %i[one_any_direction castling])
  end
end

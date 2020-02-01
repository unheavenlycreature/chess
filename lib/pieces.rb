# frozen_string_literal: true

require 'JSON'

# Base class for all chess pieces.
class ChessPiece
  attr_accessor :curr_pos
  attr_reader :owner, :start_pos, :allowed_moves

  def initialize(glyph, start_pos, color, owner, allowed_moves)
    @glyph = glyph
    @start_pos = start_pos
    @curr_pos = start_pos
    @color = color
    @owner = owner
    @allowed_moves = allowed_moves
  end

  def to_s
    @glyph.colorize(@color)
  end

  def to_json(*)
    JSON.generate({
      type: self.class.name,
      glyph: @glyph,
      start_pos: @start_pos,
      curr_pos: @curr_pos,
      color: @color,
      owner: @owner,
      allowed_moves: @allowed_moves
    })
  end
end

# A pawn in a game of chess.
class Pawn < ChessPiece
  attr_writer :allowed_moves
  def initialize(start_pos, color, owner)
    super('♟', start_pos, color, owner, %i[two_spaces_forward one_space_forward diagonal_to_take])
  end
end

# A rook in a game of chess.
class Rook < ChessPiece
  attr_writer :allowed_moves
  def initialize(start_pos, color, owner)
    super('♜', start_pos, color, owner, %i[horizontal vertical castling])
  end
end

# A knight in a game of chess.
class Knight < ChessPiece
  def initialize(start_pos, color, owner)
    super('♞', start_pos, color, owner, %i[knight])
  end
end

# A bishop in a game of chess.
class Bishop < ChessPiece
  def initialize(start_pos, color, owner)
    super('♝', start_pos, color, owner, %i[diagonal])
  end
end

# A queen in a game of chess.
class Queen < ChessPiece
  def initialize(start_pos, color, owner)
    super('♛', start_pos, color, owner, %i[horizontal vertical diagonal])
  end
end

# A king in a game of chess.
class King < ChessPiece
  attr_writer :allowed_moves
  def initialize(start_pos, color, owner)
    super('♚', start_pos, color, owner, %i[one_any_direction castling])
  end
end

# Module with convenience method to obtain
# two sets of pieces ready for a new game.
module PieceFactory
  def self.for_new_game(white_color, blue_color,
                               white_name = 'white', blue_name = 'blue')
    white_pawns = []
    blue_pawns = []
    ('a'..'h').each do |col|
      white_pawns << Pawn.new(col + '2', white_color, white_name)
      blue_pawns << Pawn.new(col + '7', blue_color, blue_name)
    end
    white_pieces = white_pawns + [
      Rook.new('a1', white_color, white_name),
      Knight.new('b1', white_color, white_name),
      Bishop.new('c1', white_color, white_name),
      Queen.new('d1', white_color, white_name),
      King.new('e1', white_color, white_name),
      Bishop.new('f1', white_color, white_name),
      Knight.new('g1', white_color, white_name),
      Rook.new('h1', white_color, white_name)
    ]
    blue_pieces = blue_pawns + [
      Rook.new('a8', blue_color, blue_name),
      Knight.new('b8', blue_color, blue_name),
      Bishop.new('c8', blue_color, blue_name),
      Queen.new('d8', blue_color, blue_name),
      King.new('e8', blue_color, blue_name),
      Bishop.new('f8', blue_color, blue_name),
      Knight.new('g8', blue_color, blue_name),
      Rook.new('h8', blue_color, blue_name)
    ]
    [white_pieces, blue_pieces]
  end

  def self.from_hash_array(hash_array)
    hash_array.map! do |piece_hash|
      piece = Object.const_get(piece_hash[:type]).new(
        piece_hash[:glyph],
        piece_hash[:color].to_sym,
        piece_hash[:owner])
      piece.curr_pos = piece_hash[:curr_pos]
      if piece.respond_to? :allowed_moves=
        piece.allowed_moves = piece_hash[:allowed_moves].map!(&:to_sym)
      end
      piece
    end
  end
end

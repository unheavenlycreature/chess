# frozen_string_literal: true

require 'colorize'

# Representation of a ChessBoard for a game of chess.
class ChessBoard
  def initialize(white_pieces, black_pieces)
    @board = initialize_board(white_pieces, black_pieces)
  end

  def to_s
    printable = @board.reverse
    column_markers = '  a  b  c  d  e  f  g  h  '.colorize(background: :black)
    s = column_markers + "\n"
    printable.each_with_index do |row, row_index|
      row_marker = (8 - row_index).to_s.colorize(background: :black)
      s += row_marker
      row.each_with_index do |piece, col_index|
        color = space_color(row_index, col_index)
        space_contents = piece.nil? ? '   ' : " #{piece} "
        s += space_contents.colorize(background: color)
      end
      s += row_marker + "\n"
    end
    s += column_markers
    s
  end

  def self.position_to_coordinates(position)
    column = position.codepoints[0] - 97
    row = position[1].to_i - 1
    [column, row]
  end

  def at(position)
    col, row = ChessBoard.position_to_coordinates(position)
    @board[row][col]
  end

  def set(position, piece)
    col, row = ChessBoard.position_to_coordinates(position)
    @board[row][col] = piece
  end

  private

  def initialize_board(white_pieces, black_pieces)
    board = []
    8.times { board << [nil] * 8 }
    (white_pieces + black_pieces).each do |piece|
      col, row = ChessBoard.position_to_coordinates(piece.starting_position)
      board[row][col] = piece
    end
    board
  end

  def space_color(row_index, col_index)
    if row_index.even?
      return col_index.even? ? :light_white : :light_black
    end

    col_index.even? ? :light_black : :light_white
  end
end
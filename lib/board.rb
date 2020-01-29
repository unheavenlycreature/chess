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
    [row, column]
  end

  def at(position)
    col, row = ChessBoard.position_to_coordinates(position)
    @board[row][col]
  end

  def set(position, piece)
    col, row = ChessBoard.position_to_coordinates(position)
    @board[row][col] = piece
  end

  def in_same_column?(from, to)
    ChessBoard.position_to_coordinates(from)[1] == \
      ChessBoard.position_to_coordinates(to)[1]
  end

  def in_same_row?(from, to)
    ChessBoard.position_to_coordinates(from)[0] == \
      ChessBoard.position_to_coordinates(to)[0]
  end

  def diagonally_accessible?(from, to)
    from_row, from_col = ChessBoard.position_to_coordinates(from)
    to_row, to_col = ChessBoard.position_to_coordinates(to)
    (from_col - to_col).abs == (from_row - to_row).abs
  end

  def vertical_path_clear?(from, to)
    from_row, col = ChessBoard.position_to_coordinates(from)
    to_row, = ChessBoard.position_to_coordinates(to)

    row_increment = from_row < to_row ? 1 : -1

    from_row += row_increment
    until from_row == to_row
      return false unless @board[from_row][col].nil?

      from_row += row_increment
    end
    true
  end

  def horizontal_path_clear?(from, to)
    row, from_col = ChessBoard.position_to_coordinates(from)
    _, to_col = ChessBoard.position_to_coordinates(to)

    col_increment = from_col < to_col ? 1 : -1

    from_col += col_increment
    until from_col == to_col
      return false unless @board[row][from_col].nil?

      from_col += col_increment
    end
    true
  end

  def diagonal_path_clear?(from, to)
    from_row, from_col = ChessBoard.position_to_coordinates(from)
    to_row, to_col = ChessBoard.position_to_coordinates(to)

    row_increment = from_row < to_row ? 1 : -1
    col_increment = from_col < to_col ? 1 : -1

    from_row += row_increment
    from_col += col_increment
    until [from_col, from_row] == [to_col, to_row]
      return false unless @board[from_row][from_col].nil?

      from_col += col_increment
      from_row += row_increment
    end
    true
  end

  def one_space_away?(from, to)
    n_rows_away?(from, to, 1) && n_columns_away?(from, to, 1)
  end

  def n_rows_away?(from, to, n)
    _from_column, from_row = ChessBoard.position_to_coordinates(from)
    _to_column, to_row = ChessBoard.position_to_coordinates(to)
    (to_row - from_row).abs == n
  end

  private

  def initialize_board(white_pieces, black_pieces)
    board = []
    8.times { board << [nil] * 8 }
    (white_pieces + black_pieces).each do |piece|
      col, row = ChessBoard.position_to_coordinates(piece.current_position)
      board[row][col] = piece
    end
    board
  end

  def n_columns_away?(from, to, n)
    from_column, _from_row = ChessBoard.position_to_coordinates(from)
    to_column, _to_row = ChessBoard.position_to_coordinates(to)
    (to_column - from_column).abs == n
  end

  def space_color(row_index, col_index)
    if row_index.even?
      return col_index.even? ? :light_white : :light_black
    end

    col_index.even? ? :light_black : :light_white
  end
end

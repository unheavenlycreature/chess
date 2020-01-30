# frozen_string_literal: true

require 'colorize'

# Representation of a ChessBoard for a game of chess.
class ChessBoard
  def initialize(white_pieces, black_pieces)
    @board = initialize_board(white_pieces, black_pieces)
  end

  def print
    puts self
  end

  def print_with_position(position)
    row, col = ChessBoard.position_to_coordinates(position)
    puts board_string(row, col)
  end

  def self.position_to_coordinates(position)
    column = position.codepoints[0] - 97
    row = position[1].to_i - 1
    [row, column]
  end

  def at(position)
    row, col = ChessBoard.position_to_coordinates(position)
    @board[row][col]
  end

  def set(position, piece)
    row, col = ChessBoard.position_to_coordinates(position)
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

  def knight_accessible?(from, to)
    from_row, from_col = ChessBoard.position_to_coordinates(from)
    to_row, to_col = ChessBoard.position_to_coordinates(to)
    ((from_col - to_col).abs == 2 && (from_row - to_row).abs == 1) || \
      ((from_col - to_col).abs == 1 && (from_row - to_row).abs == 2)
  end

  def vertical_path_clear?(from, to, allow_king_in_path = false)
    from_row, col = ChessBoard.position_to_coordinates(from)
    to_row, = ChessBoard.position_to_coordinates(to)

    row_increment = from_row < to_row ? 1 : -1

    from_row += row_increment
    until from_row == to_row
      next_piece = @board[from_row][col]
      if next_piece.nil?
        from_row += row_increment
      elsif next_piece.is_a?(King) && allow_king_in_path
        from_row += row_increment
      else
        return false
      end
    end
    true
  end

  def horizontal_path_clear?(from, to, allow_king_in_path = false)
    row, from_col = ChessBoard.position_to_coordinates(from)
    _, to_col = ChessBoard.position_to_coordinates(to)

    col_increment = from_col < to_col ? 1 : -1

    from_col += col_increment
    until from_col == to_col
      next_piece = @board[row][from_col]
      if next_piece.nil?
        from_col += col_increment
      elsif next_piece.is_a?(King) && allow_king_in_path
        from_col += col_increment
      else
        return false
      end
    end
    true
  end

  def diagonal_path_clear?(from, to, allow_king_in_path = false)
    from_row, from_col = ChessBoard.position_to_coordinates(from)
    to_row, to_col = ChessBoard.position_to_coordinates(to)

    row_increment = from_row < to_row ? 1 : -1
    col_increment = from_col < to_col ? 1 : -1

    from_row += row_increment
    from_col += col_increment
    until [from_col, from_row] == [to_col, to_row]
      next_piece = @board[from_row][from_col]
      if next_piece.nil?
        from_col += col_increment
        from_row += row_increment
      elsif next_piece.is_a?(King) && allow_king_in_path
        from_col += col_increment
        from_row += row_increment
      else
        return false
      end
    end
    true
  end

  def one_space_away?(from, to)
    from_row, from_col = ChessBoard.position_to_coordinates(from)
    to_row, to_col = ChessBoard.position_to_coordinates(to)

    (to_col - from_col).abs <= 1 && (to_row - from_row).abs <= 1
  end

  def n_rows_away?(from, to, n)
    from_row, = ChessBoard.position_to_coordinates(from)
    to_row, = ChessBoard.position_to_coordinates(to)
    (to_row - from_row).abs == n
  end

  def n_columns_away?(from, to, n)
    _, from_column = ChessBoard.position_to_coordinates(from)
    _, to_column = ChessBoard.position_to_coordinates(to)
    (to_column - from_column).abs == n
  end

  private

  def to_s
    board_string
  end

  def board_string(h_row = nil, h_col = nil)
    printable = @board.reverse
    column_markers = "\n    a  b  c  d  e  f  g  h  "
    s = column_markers + "\n\n"
    printable.each_with_index do |row, row_index|
      row_marker = (8 - row_index).to_s
      s += "#{row_marker}  "
      row.each_with_index do |piece, col_index|
        color = space_color(row_index, col_index, h_row, h_col)
        space_contents = piece.nil? ? '   ' : " #{piece} "
        s += space_contents.colorize(background: color)
      end
      s += "  #{row_marker}\n"
    end
    s += "#{column_markers}\n\n"
  end

  def initialize_board(white_pieces, black_pieces)
    board = []
    8.times { board << [nil] * 8 }
    (white_pieces + black_pieces).each do |piece|
      row, col = ChessBoard.position_to_coordinates(piece.curr_pos)
      board[row][col] = piece
    end
    board
  end

  def space_color(row_index, col_index, h_row, h_col)
    return :light_green if (7 - row_index).abs == h_row && col_index == h_col

    if row_index.even?
      return col_index.even? ? :light_black : :black
    end

    col_index.even? ? :black : :light_black
  end
end

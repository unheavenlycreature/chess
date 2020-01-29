# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'

# Manages a game of chess played by two players.
class ChessManager
  def initialize
    if new_game?
      @white_name, @black_name = new_player_names
      @white_pieces, @black_pieces = \
        InitialPieces.pieces_for_new_game(@white_name, @black_name)
      @board = ChessBoard.new(@white_pieces, @black_pieces)
      @current_player = @white_name
      @current_pieces = @white_pieces
      play
    else
      # TODO: Implement game loading.
    end
  end

  private

  def play
    until game_over?
      next_turn
      switch_players
    end
  end

  def next_turn
    puts @board
    eligible_move = false
    until eligible_move
      piece = select_piece
      desired_position = new_position
      eligible_move = eligible_move?(piece, desired_position)
    end

    @board.at(desired_position).current_position = nil \
      if opposing_player_has_piece?(desired_position)

    @board.set(piece.current_position, nil)
    piece.current_position = desired_position
    @board.set(desired_position, piece)
  end

  def switch_players
    if @current_player == @white_name
      @current_player = @black_name
      @current_pieces = @black_pieces
      return
    end

    @current_player = @white_name
    @current_pieces = @white_pieces
  end

  def game_over?
    # TODO: implement game terminating logic.
    false
  end

  def remove_special_move_from_piece(piece, move_type)
    unless %i[one_any_direction castling one_space_forward two_spaces_forward].include?(move_type)
      return
    end

    piece.allowed_moves = piece.allowed_moves.filter do |move|
      !%i[castling two_spaces_forward].include?(move)
    end
  end

  def eligible_move?(piece, desired_position)
    # TODO: include checkmate restrictions and en passing piece removal.
    piece.allowed_moves.each do |move_type|
      if can_move_to_position_via?(piece, desired_position, move_type)
        remove_special_move_from_piece(piece, move_type)
        return true
      end
    end
    puts "That move isn't valid."
    false
  end

  def forward_move?(piece, to)
    if piece.starting_position[1].to_i > 6
      return to[1].to_i < piece.current_position[1].to_i
    end
    to[1].to_i > piece.current_position[1].to_i
  end

  def can_move_to_position_via?(piece, to, move_type)
    return false if player_has_piece?(to)

    from = piece.current_position
    case move_type
    when :two_spaces_forward
      @board.in_same_column?(from, to) && \
        @board.n_rows_away?(from, to, 2) && \
        @board.vertical_path_clear?(from, to) && \
        forward_move?(piece, to)
    when :one_space_forward
      @board.in_same_column?(from, to) && \
        @board.n_rows_away?(from, to, 1) && \
        @board.vertical_path_clear?(from, to) && \
        forward_move?(piece, to)
    when :diagonal_to_take
      @board.diagonally_accessible?(from, to) && \
        @board.one_space_away?(from, to) && \
        forward_move?(piece, to) && \
        opposing_player_has_piece?(to)
    when :horizontal
      @board.in_same_row?(from, to) && \
        @board.horizontal_path_clear?(from, to)
    when :vertical
      @board.in_same_column?(from, to) && \
        @board.vertical_path_clear?(from, to)
    when :diagonal
      @board.diagonally_accessible?(from, to) &&
        @board.diagonal_path_clear?(from, to)
    when :knight
      false
    when :one_any_direction
      # TODO handle moving into check.
      @board.one_space_away?(from, to)
    when :castling
      false
    end
  end

  def select_piece
    puts "Which piece are you moving #{@current_player}?"
    position = gets.chomp
    until valid_position?(position) && player_has_piece?(position)
      puts "You don't have a piece there. Pick another position."
      position = gets.chomp
    end
    @board.at(position)
  end

  def player_has_piece?(position)
    piece = @board.at(position)
    !piece.nil? && piece.owner == @current_player
  end

  def opposing_player_has_piece?(position)
    piece = @board.at(position)
    !piece.nil? && piece.owner != @current_player
  end

  def new_position
    puts 'Where do you want to move your piece?'
    desired_position = gets.chomp
    until valid_position?(desired_position)
      puts "That's not a valid position on the board."
      puts 'Please enter a new position.'
      desired_position = gets.chomp
    end
    desired_position
  end

  def valid_position?(position)
    position.length == 2 && \
      ('a'..'h').include?(position[0].downcase) && \
      ('1'..'8').include?(position[1])
  end

  def new_game?
    puts 'Would you like to start a new game? [y/n]'
    option = gets.chomp
    option.downcase == 'y'
  end

  def new_player_names
    puts 'Who is playing as white?'
    white_name = gets.chomp
    puts 'Who is playing as black?'
    black_name = gets.chomp
    [white_name, black_name]
  end
end

ChessManager.new
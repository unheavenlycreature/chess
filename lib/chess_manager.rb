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
      piece, curr_position = piece_and_position
      desired_position = new_position
      eligible_move = eligible_move?(piece, curr_position, desired_position)
    end
    @board.set(curr_position, nil)
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

  def eligible_move?(_piece, _curr_position, _desired_position)
    # TODO: implement move eligibility logic.
    true
  end

  def piece_and_position
    puts "Which piece are you moving #{@current_player}?"
    position = gets.chomp
    until valid_position?(position) && player_has_piece?(position)
      puts "You don't have a piece there. Pick another position."
      position = gets.chomp
    end
    piece = @board.at(position)
    [piece, position]
  end

  def player_has_piece?(position)
    piece = @board.at(position)
    !piece.nil? && piece.owner == @current_player
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
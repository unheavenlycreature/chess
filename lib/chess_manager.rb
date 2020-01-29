# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'

# Manages a game of chess played by two players.
class ChessManager
  def initialize
    if new_game?
      @current_name, @opponent_name = new_player_names
      @current_pieces, @opponent_pieces = \
        InitialPieces.pieces_for_new_game(@current_name, @opponent_name)
      @board = ChessBoard.new(@current_pieces, @opponent_pieces)
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
    made_move = false
    until made_move
      piece = select_piece
      desired_position = new_position
      made_move = made_move?(piece, desired_position)
    end
  end

  def switch_players
    temp_name = @current_name
    temp_pieces = @current_pieces
    @current_name = @opponent_name
    @current_pieces = @opponent_pieces
    @opponent_name = temp_name
    @opponent_pieces = temp_pieces
  end

  def game_over?
    # TODO: implement game terminating logic.
    false
  end

  def remove_special_move_from_piece(piece)
    piece.allowed_moves = piece.allowed_moves.filter do |move|
      !%i[castling two_spaces_forward].include?(move)
    end
  end

  def remove_en_passant_from_pawns
    @current_pieces.each do |piece|
      next unless piece.is_a? Pawn

      piece.allowed_moves.keep_if { |move| move != :en_passant }
    end
  end

  def setup_en_passant(piece, desired_position)
    @targetable_by_en_passant = piece

    if piece.current_position[1].to_i > desired_position[1].to_i
      @en_passant_position = piece.current_position[0] + \
        (piece.current_position[1].to_i - 1).to_s
    else 
      @en_passant_position = piece.current_position[0] + \
        (piece.current_position[1].to_i + 1).to_s
    end
    apply_en_passant_to_opponent_pawns(desired_position)
  end

  def apply_en_passant_to_opponent_pawns(new_pawn_position)
    @opponent_pieces.each do |piece|
      next unless piece.is_a? Pawn

      piece.allowed_moves << :en_passant if @board.in_same_row?(piece.current_position, new_pawn_position) && \
                                            @board.n_columns_away?(piece.current_position, new_pawn_position, 1)
    end
  end

  def remove_targeted_piece
    @board.set(@targetable_by_en_passant.current_position, nil)
    @targetable_by_en_passant.current_position = nil
  end

  def reset_en_passant
    @targetable_by_en_passant = nil
    @en_passant_position = nil
  end

  def make_move(piece, desired_position, move_type)
    remove_special_move_from_piece(piece)

    # Inform opponent's piece it was removed.
    @board.at(desired_position).current_position = nil \
      if player_has_piece?(desired_position, @opponent_name)

    # Prepare opponent pawns for en passant.
    if move_type == :two_spaces_forward
      setup_en_passant(piece, desired_position)
    end

    # Remove opponent's pawn if it was captured by en_passant.
    remove_targeted_piece if move_type == :en_passant

    # Move the piece to the new position
    @board.set(piece.current_position, nil)
    piece.current_position = desired_position
    @board.set(desired_position, piece)

    reset_en_passant unless move_type == :two_spaces_forward
    remove_en_passant_from_pawns unless move_type == :two_spaces_forward
  end

  def made_move?(piece, desired_position)
    # TODO: include checkmate restrictions and en passing piece removal.
    piece.allowed_moves.each do |move_type|
      next unless can_move_to_position_via?(piece, desired_position, move_type)

      make_move(piece, desired_position, move_type)
      return true
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
    return false if player_has_piece?(to, @current_name)

    from = piece.current_position
    case move_type
    when :en_passant then to == @en_passant_position
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
        player_has_piece?(to, @opponent_name)
    when :horizontal
      @board.in_same_row?(from, to) && \
        @board.horizontal_path_clear?(from, to)
    when :vertical
      @board.in_same_column?(from, to) && \
        @board.vertical_path_clear?(from, to)
    when :diagonal
      @board.diagonally_accessible?(from, to) && \
        @board.diagonal_path_clear?(from, to)
    when :knight then @board.knight_accessible?(from, to)
    # TODO: handle moving into check.
    when :one_any_direction then @board.one_space_away?(from, to)
    when :castling then false
    end
  end

  def select_piece
    puts "Which piece are you moving #{@current_name}?"
    position = gets.chomp
    until valid_position?(position) && player_has_piece?(position, @current_name)
      puts "You don't have a piece there. Pick another position."
      position = gets.chomp
    end
    @board.at(position)
  end

  def player_has_piece?(position, player)
    piece = @board.at(position)
    !piece.nil? && piece.owner == player
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
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
      @current_king, @opponent_king = find_kings
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
      if king_in_check?
        piece = @current_king
        puts 'Your king is in check. Where will you move it?'
      else
        piece = select_piece
        puts 'Where do you want to move your piece?'
      end
      desired_position = new_position
      made_move = made_move?(piece, desired_position)
    end
  end

  def switch_players
    temp_name = @current_name
    temp_king = @current_king
    temp_pieces = @current_pieces
    @current_name = @opponent_name
    @current_king = @opponent_king
    @current_pieces = @opponent_pieces
    @opponent_name = temp_name
    @opponent_king = temp_king
    @opponent_pieces = temp_pieces
  end

  def game_over?
    return false unless checkmate?

    puts "Checkmate! #{@opponent_name} wins!"
    true
  end

  def checkmate?
    king_adjacent_open_spaces = \
      adjacent_spaces(@current_king.current_position).delete_if do |position|
        !@board.at(position).nil?
      end

    return false if king_adjacent_open_spaces.empty?

    king_adjacent_open_spaces.all? do |space|
      @opponent_pieces.any? do |piece|
        piece.allowed_moves.any? do |move|
          can_move_to_position_via?(piece, space, move, true)
        end
      end
    end
  end

  def king_in_check?
    @opponent_pieces.any? do |piece|
      piece_can_reach?(piece, @current_king.current_position)
    end
  end

  def piece_can_reach?(piece, position)
    piece.allowed_moves.any? do |move|
      can_move_to_position_via?(piece, position, move, true)
    end
  end

  def adjacent_spaces(position)
    col = position[0]
    row = position[1]
    arr = [col, row]

    case col
    when 'a' then arr << 'b'
    when 'g' then arr << 'h'
    else
      arr << col.next
      arr << (col.ord - 1).chr
    end

    case row
    when '1' then arr << '2'
    when '8' then arr << '7'
    else
      arr << row.next
      arr << (row.ord - 1).chr
    end

    arr.permutation(2).filter do |perm|
      ('a'..'h').include?(perm[0]) && ('1'..'8').include?(perm[1]) && \
        perm[0] + perm[1] != position
    end.map(&:join)
  end

  def spaces_on_horiz_path(from, to)
    spaces = []
    from_col = from[0].codepoints[0]
    to_col = to[0].codepoints[0]
    range_start = from_col < to_col ? from_col + 1 : to_col + 1
    range_end = range_start == from_col + 1 ? to_col - 1 : from_col - 1
    (range_start..range_end).each do |col|
      spaces << col.chr + to[1]
    end
    spaces
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
    @opponent_pieces.delete_if { |piece| piece == @targetable_by_en_passant }
  end

  def reset_en_passant
    @targetable_by_en_passant = nil
    @en_passant_position = nil
  end

  def make_move(piece, desired_position, move_type)
    # Remove the opponent's piece from play.
    if player_has_piece?(desired_position, @opponent_name)
      to_remove = @board.at(desired_position)
      @opponent_pieces.delete_if { |op| op == to_remove }
    end
    @board.at(desired_position).current_position = nil \
      if player_has_piece?(desired_position, @opponent_name)

    # If the king castled, move the rook as well.
    if move_type == :castling
      move_castling_rook(piece.current_position, desired_position)
    end

    # Prepare opponent pawns for en passant.
    if move_type == :two_spaces_forward
      setup_en_passant(piece, desired_position)
    end

    # Remove moves that are only allowed once per game from the piece.
    if %i[two_spaces_forward castling].include?(move_type)
      piece.allowed_moves.keep_if { |move| move != move_type }
    end

    # Remove opponent's pawn if it was captured by en_passant.
    remove_targeted_piece if move_type == :en_passant

    # Move the piece to the new position
    move_piece_to_position(piece, desired_position)

    reset_en_passant unless move_type == :two_spaces_forward
    remove_en_passant_from_pawns unless move_type == :two_spaces_forward

    promote_if_eligible(piece) if piece.is_a?(Pawn)
  end

  def promote_if_eligible(pawn)
    return unless reached_opposite_side(pawn)

    puts 'Your pawn can be promoted!'
    selection_message = 'Choose a Bishop (B), Rook (R), Knight (K), or Queen (Q)'
    puts selection_message
    selection = gets.chomp.upcase
    until %w[B R K Q].include?(selection)
      puts "I didn't understand that."
      puts selection_message
      selection = gets.chomp
    end
    promote(pawn, selection)
  end

  def promote(pawn, selection)
    pawn_position = pawn.current_position
    case selection
    when 'B'
      promotion_piece = Bishop.new('♝', pawn_position, @current_name)
    when 'R'
      promotion_piece = Rook.new('♜', pawn_position, @current_name)
    when 'K'
      promotion_piece = Knight.new('♞', pawn_position, @current_name)
    when 'Q'
      promotion_piece = Queen.new('♛', pawn_position, @current_name)
    end
    puts "#{promotion_piece} #{promotion_piece.current_position}"
    move_piece_to_position(promotion_piece, pawn_position)
    @current_pieces << promotion_piece
    @current_pieces.delete_if { |piece| piece == pawn }
  end

  def reached_opposite_side(pawn)
    (pawn.starting_position[1] == '2' && pawn.current_position[1] == '8') || \
      (pawn.starting_position[1] == '7' && pawn.current_position[1] == '1')
  end

  def made_move?(piece, desired_position)
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

  def can_move_to_position_via?(piece, to, move_type, testing_for_check = false)
    player_making_move = testing_for_check ? @opponent_name : @current_name
    return false if player_has_piece?(to, player_making_move)

    from = piece.current_position
    send("#{move_type}_eligible?", piece, from, to, testing_for_check)
  end

  def en_passant_eligible?(_piece, _from, to, testing_for_check)
    return false if testing_for_check

    to == @en_passant_position
  end

  def two_spaces_forward_eligible?(piece, from, to, testing_for_check)
    return false if testing_for_check

    @board.in_same_column?(from, to) && \
      @board.n_rows_away?(from, to, 2) && \
      @board.vertical_path_clear?(from, to) && \
      forward_move?(piece, to) && !player_has_piece?(to, @opponent_name)
  end

  def one_space_forward_eligible?(piece, from, to, testing_for_check)
    return false if testing_for_check

    @board.in_same_column?(from, to) && \
      @board.n_rows_away?(from, to, 1) && \
      @board.vertical_path_clear?(from, to) && \
      forward_move?(piece, to) && !player_has_piece?(to, @opponent_name)
  end

  def diagonal_to_take_eligible?(piece, from, to, testing_for_check)
    precondition = @board.diagonally_accessible?(from, to) && \
                   @board.one_space_away?(from, to) && forward_move?(piece, to)
    return precondition if testing_for_check

    precondition && player_has_piece?(to, @opponent_name)
  end

  def horizontal_eligible?(_piece, from, to, allow_king_in_path)
    @board.in_same_row?(from, to) && \
      @board.horizontal_path_clear?(from, to, allow_king_in_path)
  end

  def vertical_eligible?(_piece, from, to, allow_king_in_path)
    @board.in_same_column?(from, to) && \
      @board.vertical_path_clear?(from, to, allow_king_in_path)
  end

  def diagonal_eligible?(_piece, from, to, allow_king_in_path)
    @board.diagonally_accessible?(from, to) && \
      @board.diagonal_path_clear?(from, to, allow_king_in_path)
  end

  def knight_eligible?(_piece, from, to, _testing_for_check)
    @board.knight_accessible?(from, to)
  end

  def one_any_direction_eligible?(_piece, from, to, testing_for_check)
    return false if testing_for_check

    @board.one_space_away?(from, to) && \
      @opponent_pieces.none? do |piece|
        piece_can_reach?(piece, to)
      end
  end

  def castling_eligible?(_piece, from, to, _testing_for_check)
    @rook_positions = {
      %w[e1 c1] => 'a1',
      %w[e1 g1] => 'h1',
      %w[e8 c8] => 'a8',
      %w[e8 g8] => 'h8'
    }

    rook_position = @rook_positions[[from, to]]
    return false if rook_position.nil? || !castling_rook_present?(rook_position)

    return false unless @board.horizontal_path_clear?(from, rook_position)

    spaces_on_horiz_path(from, to).all? do |space|
      @board.at(space).nil? && @opponent_pieces.none? do |piece|
        piece_can_reach?(piece, space)
      end
    end
  end

  def move_castling_rook(king_from, king_to)
    rook_position = @rook_positions[[king_from, king_to]]
    new_positions = {
      'a1' => 'd1',
      'h1' => 'f1',
      'a8' => 'd8',
      'h8' => 'f8'
    }

    rook = @board.at(rook_position)
    new_position = new_positions[rook_position]
    move_piece_to_position(rook, new_position)
    rook.allowed_moves.keep_if { |move| move != :castling }
  end

  def castling_rook_present?(position)
    rook = @board.at(position)
    !rook.nil? && rook.is_a?(Rook) && rook.allowed_moves.include?(:castling)
  end

  def move_piece_to_position(piece, position)
    @board.set(piece.current_position, nil)
    @board.set(position, piece)
    piece.current_position = position
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

  def find_kings
    current_king = @current_pieces.select do |piece|
      piece.is_a?(King)
    end[0]
    opponent_king = @opponent_pieces.select do |piece|
      piece.is_a?(King)
    end[0]
    [current_king, opponent_king]
  end
end

ChessManager.new

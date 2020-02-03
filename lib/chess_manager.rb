# frozen_string_literal: true

require 'JSON'
require_relative 'board'
require_relative 'pieces'

# Manages a game of chess played by two players on the command-line.
class ChessManager
  def initialize(current_name, opponent_name, current_pieces, opponent_pieces)
    @current_name = current_name
    @opponent_name = opponent_name
    @current_pieces = current_pieces
    @opponent_pieces = opponent_pieces
    @current_king, @opponent_king = kings
    @board = ChessBoard.new(@current_pieces, @opponent_pieces)
  end

  def play
    until game_over?
      next_turn
      switch_players
    end
  end

  private

  def next_turn
    @board.print
    made_move = false
    until made_move
      if king_in_check?
        piece = @current_king
        @board.print_with_position(piece.curr_pos)
        print 'Your king is in check! Where will you move it? '
      else
        piece = select_piece_or_save_and_exit
        @board.print_with_position(piece.curr_pos)
        print 'Where do you want to move your piece? '
      end
      position = new_position_or_save_and_exit(piece.curr_pos)
      made_move = made_move?(piece, position)
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
    if checkmate?
      puts "Checkmate! #{opponent_name} wins!"
      true
    elsif insufficient_material?
      puts "Insufficient material! It's a draw!"
      true
    elsif stalemate?
      puts "Stalemate! It's a draw!"
      true
    end

    false
  end

  def insufficient_material?
    only_kings? || \
      kings_and_knights?(@current_pieces, @opponent_pieces) || \
      kings_and_knights?(@opponent_pieces, @current_pieces) || \
      kings_and_bishop?(@current_pieces, @opponent_pieces) || \
      kings_and_bishop?(@opponent_pieces, @current_pieces) || \
      kings_and_bishops?
  end

  def only_kings?
    @current_pieces.all? { |piece| piece.is_a?(King) } && \
      @opponent_pieces.all? { |piece| piece.is_a?(King) }
  end

  def kings_and_knights?(king_only, king_and_knights)
    king_only.all? { |piece| piece.is_a?(King) } && \
      king_and_knights.size < 4 && \
      king_and_knights.all? do |piece|
        piece.is_a?(King) || piece.is_a?(Knight)
      end
  end

  def kings_and_bishop?(king_only, king_and_bishop)
    king_only.all? { |piece| piece.is_a?(King) } && \
      king_and_bishop.size == 2 && \
      king_and_bishop.all? do |piece|
        piece.is_a?(King) || piece.is_a?(Bishop)
      end
  end

  def kings_and_bishops?
    pieces = @current_pieces.union(@opponent_pieces)

    return false if pieces.size > 4

    white_squares = %w[c8 f1]
    bishops = pieces.filter do |piece|
      piece.is_a?(Bishop)
    end

    bishops.all? { |b| white_squares.include?(b.start_pos) } || \
      bishops.none? { |b| white_squares.include?(b.start_pos) }
  end

  def checkmate?
    king_adjacent_open_spaces = \
      adjacent_spaces(@current_king.curr_pos).delete_if do |position|
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

  def stalemate?
    # TODO: implement stalemate.
  end

  def king_in_check?
    @opponent_pieces.any? do |piece|
      piece_can_reach?(piece, @current_king.curr_pos)
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

    if piece.curr_pos[1].to_i > desired_position[1].to_i
      @en_passant_position = piece.curr_pos[0] + \
                             (piece.curr_pos[1].to_i - 1).to_s
    else
      @en_passant_position = piece.curr_pos[0] + \
                             (piece.curr_pos[1].to_i + 1).to_s
    end
    apply_en_passant_to_opponent_pawns(desired_position)
  end

  def apply_en_passant_to_opponent_pawns(new_pawn_position)
    @opponent_pieces.each do |piece|
      next unless piece.is_a? Pawn

      piece.allowed_moves << :en_passant if @board.in_same_row?(piece.curr_pos, new_pawn_position) && \
                                            @board.n_columns_away?(piece.curr_pos, new_pawn_position, 1)
    end
  end

  def remove_targeted_piece
    @board.set(@targetable_by_en_passant.curr_pos, nil)
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

    # If the king castled, move the rook as well.
    if move_type == :castling
      move_castling_rook(piece.curr_pos, desired_position)
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
    pawn_position = pawn.curr_pos
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
    move_piece_to_position(promotion_piece, pawn_position)
    @current_pieces << promotion_piece
    @current_pieces.delete_if { |piece| piece == pawn }
  end

  def reached_opposite_side(pawn)
    (pawn.start_pos[1] == '2' && pawn.curr_pos[1] == '8') || \
      (pawn.start_pos[1] == '7' && pawn.curr_pos[1] == '1')
  end

  def made_move?(piece, desired_position)
    piece.allowed_moves.each do |move_type|
      next unless can_move_to_position_via?(piece, desired_position, move_type)

      make_move(piece, desired_position, move_type)
      return true
    end
    @board.print
    puts 'Sorry, that move is invalid.'
    false
  end

  def forward_move?(piece, to)
    return to[1].to_i < piece.curr_pos[1].to_i if piece.start_pos[1].to_i > 6

    to[1].to_i > piece.curr_pos[1].to_i
  end

  def can_move_to_position_via?(piece, to, move_type, testing_for_check = false)
    player_making_move = testing_for_check ? @opponent_name : @current_name
    return false if player_has_piece?(to, player_making_move)

    from = piece.curr_pos
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
    @board.set(piece.curr_pos, nil)
    @board.set(position, piece)
    piece.curr_pos = position
  end

  def select_piece_or_save_and_exit
    print "Which piece are you moving #{@current_name}? "
    position = gets.chomp
    valid_pos_or_save = valid_position_or_save?(position)
    save_and_exit if position.downcase == 's'
    has_piece = player_has_piece?(position, @current_name)
    until valid_pos_or_save && has_piece
      @board.print
      if !valid_pos_or_save
        print "That's not a valid position on the board. Pick another position. "
      elsif !has_piece
        print "You don't have a piece there. Pick another position. "
      end
      position = gets.chomp
      valid_pos_or_save = valid_position_or_save?(position)
      save_and_exit if position.downcase == 's'
      has_piece = player_has_piece?(position, @current_name)
    end
    @board.at(position)
  end

  def player_has_piece?(position, player)
    piece = @board.at(position)
    !piece.nil? && piece.owner == player
  end

  def new_position_or_save_and_exit(curr_pos)
    position_or_save = gets.chomp
    until valid_position_or_save?(position_or_save)
      @board.print_with_position(curr_pos)
      print "That's not a valid position on the board. Pick another position. "
      position_or_save = gets.chomp
    end
    save_and_exit if position_or_save.downcase == 's'
    position_or_save
  end

  def valid_position_or_save?(position)
    (position.downcase == 's') || \
      position.length == 2 && \
        ('a'..'h').include?(position[0].downcase) && \
        ('1'..'8').include?(position[1])
  end

  def kings
    current_king = @current_pieces.select do |piece|
      piece.is_a?(King)
    end[0]
    opponent_king = @opponent_pieces.select do |piece|
      piece.is_a?(King)
    end[0]
    [current_king, opponent_king]
  end

  def save_and_exit
    file, filename = create_save_file
    JSON.dump({
                current_name: @current_name,
                opponent_name: @opponent_name,
                current_pieces: @current_pieces,
                opponent_pieces: @opponent_pieces
              }, file)
    file.close
    puts "Game saved to #{filename}. Goodbye!"
    exit
  end

  def create_save_file
    save_dir = 'saves'
    Dir.mkdir(save_dir) unless Dir.exist? save_dir
    filename = \
      "#{save_dir}/#{@current_name}_v_#{@opponent_name}_#{Time.now.to_i}"
    [File.open(filename, 'w'), filename]
  end
end

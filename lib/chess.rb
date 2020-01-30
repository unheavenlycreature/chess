# frozen_string_literal: true

require_relative 'chess_manager'

# Initiates a game of chess played on the command-line.
class Chess
  def play
    manager = if new_game?
                new_manager
              else
                manager_from_save
              end
    manager.play
  end

  private

  def new_game?
    print 'Would you like to start a new game? [Y/N] '
    option = gets.chomp
    option.upcase == 'Y'
  end

  def new_manager
    current_name, opponent_name = new_player_names
    current_pieces, opponent_pieces = \
      InitialPieces.pieces_for_new_game(
        :light_white, :blue,
        current_name, opponent_name
      )
    ChessManager.new(current_name, opponent_name, current_pieces,
                     opponent_pieces)
  end

  def new_player_names
    names = []
    %w[white blue].each do |color|
      print "Who is playing as #{color}? "
      names << gets.chomp
    end
    names
  end

  def manager_from_save
    print 'Loading from saves not yet supported. Sorry!'
    exit
  end
end

Chess.new.play

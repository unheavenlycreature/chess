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
      PieceFactory.for_new_game(
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
    print "What's the name of your save file? "
    filename = gets.chomp
    until File.exist? filename
      puts "That file doesn't exist."
      print "Give me a new name, start a new game with 'n', or exit with 'q'. "
      filename = gets.chomp
      return new_manager if filename.downcase == 'n'
      exit if filename.downcase == 'q'
    end
    save_state = parse_save_file(filename)
    ChessManager.new(
      save_state[:current_name], 
      save_state[:opponent_name],
      PieceFactory.from_hash_array(save_state[:current_pieces]),
      PieceFactory.from_hash_array(save_state[:opponent_pieces]),
    )
  end

  def parse_save_file(filename)
    file = File.open(filename)
    save_state = JSON.parse(file.read, symbolize_names: true)
    file.close
    save_state
  end
end

Chess.new.play

# frozen_string_literal: true

require './lib/board'
require './lib/pieces'

describe ChessBoard do
  before :each do
    @board = ChessBoard.new([], [])
  end

  context 'ChessBoard#position_to_coordinates' do
    it 'maps a1 to [0, 0]' do
      expect(ChessBoard.position_to_coordinates('a1')).to eq([0, 0])
    end

    it 'maps h8 to [7, 7]' do
      expect(ChessBoard.position_to_coordinates('h8')).to eq([7, 7])
    end
  end

  context '#at' do
    it 'returns nil for empty spaces' do
      @board.all_spaces.each do |space|
        expect(@board.at(space).nil?).to be true
      end
    end
  end

  context '#set' do
    it 'places piece in expected position' do
      expect(@board.at('a3').nil?).to be true
      pawn = Pawn.new('a3', :light_white, 'test')
      @board.set('a3', pawn)
      expect(@board.at('a3')).to eq(pawn)
    end
  end

  context '#in_same_column?' do
    column_a = %w[a1 a2 a3 a4 a5 a6 a7 a8]

    it 'returns true for same columns' do
      column_a.permutation(2).each do |pair|
        expect(@board.in_same_column?(pair[0], pair[1])).to be true
      end
    end

    it 'returns false for different columns' do
      other_spaces = @board.all_spaces - column_a
      column_a.each do |col_a_space|
        other_spaces.each do |other_space|
          expect(@board.in_same_column?(col_a_space, other_space)).to be false
        end
      end
    end
  end

  context '#in_same_row?' do
    row_1 = %w[a1 b1 c1 d1 e1 f1 g1 h1]

    it 'returns true for same rows' do
      row_1.permutation(2).each do |pair|
        expect(@board.in_same_row?(pair[0], pair[1])).to be true
      end
    end

    it 'returns false for different rows' do
      other_spaces = @board.all_spaces - row_1
      row_1.each do |row_1_space|
        other_spaces.each do |other_space|
          expect(@board.in_same_row?(row_1_space, other_space)).to be false
        end
      end
    end
  end

  context '#diagonally_accessible?' do
    it 'returns true for diagonally accessible path' do
      expect(@board.diagonally_accessible?('a1', 'h8')).to be true
    end

    it 'returns false for diagonally inaccessible path' do
      expect(@board.diagonally_accessible?('a1', 'h7')).to be false
    end
  end

  context '#knight_accessible?' do
    start = 'e4'
    accessible_spaces = %w[c3 c5 d2 d6 f2 f6 g3 g5]

    it 'returns true for accessible spaces' do
      accessible_spaces.each do |space|
        expect(@board.knight_accessible?(start, space)).to be true
      end
    end

    it 'returns false for accessible spaces' do
      inaccessible_spaces = @board.all_spaces - accessible_spaces
      inaccessible_spaces.each do |space|
        expect(@board.knight_accessible?(start, space)).to be false
      end
    end
  end

  context '#vertical_path_clear?' do
    context 'disallow king in path' do
      it 'returns true for clear path' do
        expect(@board.vertical_path_clear?('a1', 'a8')).to be true
      end

      it 'returns false for piece in path' do
        @board.set('a7', Pawn.new('a7', :blue, 'test'))
        expect(@board.vertical_path_clear?('a1', 'a8')).to be false
      end

      it 'returns false for king in path' do
        @board.set('a7', King.new('a7', :blue, 'test'))
        expect(@board.vertical_path_clear?('a1', 'a8')).to be false
      end
    end

    context 'allow king in path' do
      it 'returns true for clear path' do
        expect(@board.vertical_path_clear?('a1', 'a8', true)).to be true
      end

      it 'returns false for piece in path' do
        @board.set('a7', Pawn.new('a7', :blue, 'test'))
        expect(@board.vertical_path_clear?('a1', 'a8', true)).to be false
      end

      it 'returns true for king in path' do
        @board.set('a7', King.new('a7', :blue, 'test'))
        expect(@board.vertical_path_clear?('a1', 'a8', true)).to be true
      end
    end
  end

  context 'horizontal_path_clear?' do
    context 'disallow king in path' do
      it 'returns true for clear path' do
        expect(@board.horizontal_path_clear?('a1', 'h1')).to be true
      end

      it 'returns false for piece in path' do
        @board.set('g1', Pawn.new('g1', :blue, 'test'))
        expect(@board.horizontal_path_clear?('a1', 'h1')).to be false
      end

      it 'returns false for king in path' do
        @board.set('g1', King.new('g1', :blue, 'test'))
        expect(@board.horizontal_path_clear?('a1', 'h1')).to be false
      end
    end

    context 'allow king in path' do
      it 'returns true for clear path' do
        expect(@board.horizontal_path_clear?('a1', 'h1', true)).to be true
      end

      it 'returns false for piece in path' do
        @board.set('g1', Pawn.new('g1', :blue, 'test'))
        expect(@board.horizontal_path_clear?('a1', 'h1', true)).to be false
      end

      it 'returns true for king in path' do
        @board.set('g1', King.new('g1', :blue, 'test'))
        expect(@board.horizontal_path_clear?('a1', 'h1', true)).to be true
      end
    end
  end

  context '#diagonal_path_clear?' do
    context 'disallow king in path' do
      it 'returns true for clear path' do
        expect(@board.diagonal_path_clear?('a1', 'h8')).to be true
      end

      it 'returns false for piece in path' do
        @board.set('g7', Pawn.new('g7', :blue, 'test'))
        expect(@board.diagonal_path_clear?('a1', 'h8')).to be false
      end

      it 'returns false for king in path' do
        @board.set('g7', King.new('g7', :blue, 'test'))
        expect(@board.diagonal_path_clear?('a1', 'h8')).to be false
      end
    end

    context 'allow king in path' do
      it 'returns true for clear path' do
        expect(@board.diagonal_path_clear?('a1', 'h8', true)).to be true
      end

      it 'returns false for piece in path' do
        @board.set('g7', Pawn.new('g7', :blue, 'test'))
        expect(@board.diagonal_path_clear?('a1', 'h8', true)).to be false
      end

      it 'returns true for king in path' do
        @board.set('g7', King.new('g7', :blue, 'test'))
        expect(@board.diagonal_path_clear?('a1', 'h8', true)).to be true
      end
    end
  end

  context '#one_space_away?' do
    start = 'e4'
    one_space_away = %w[d3 d4 d5 e3 e5 f3 f4 f5]
    it 'returns true for one space away' do
      one_space_away.each do |space|
        expect(@board.one_space_away?(start, space)).to be true
      end
    end

    it 'returns false for all other spaces' do
      other_spaces = @board.all_spaces - one_space_away
      other_spaces.each do |space|
        expect(@board.one_space_away?(start, space)).to be false
      end
    end
  end

  context '#n_rows_away?' do
    start = 'e4'
    two_rows_away = %w[a2 a6 b2 b6 c2 c6 d2 d6 e2 e6 f2 f6 g2 g6 h2 h6] 

    it 'returns true for spaces 2 rows away when n = 2' do
      two_rows_away.each do |space|
        expect(@board.n_rows_away?(start, space, 2)).to be true
      end
    end

    it 'returns false for other spaces when n = 2' do
      other_spaces = @board.all_spaces - two_rows_away
       other_spaces.each do |space|
        expect(@board.n_rows_away?(start, space, 2)).to be false
      end
    end
  end

  context '#n_columns_away?' do
    start = 'e4'
    two_columns_away = %w[c1 c2 c3 c4 c5 c6 c7 c8 g1 g2 g3 g4 g5 g6 g7 g8] 

    it 'returns true for spaces 2 columns away when n = 2' do
      two_columns_away.each do |space|
        expect(@board.n_columns_away?(start, space, 2)).to be true
      end
    end

    it 'returns false for other spaces when n = 2' do
      other_spaces = @board.all_spaces - two_columns_away
       other_spaces.each do |space|
        expect(@board.n_columns_away?(start, space, 2)).to be false
      end
    end
  end
end

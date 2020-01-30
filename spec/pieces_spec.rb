# frozen_string_literal: true

require './lib/pieces'

describe ChessPiece do
  before :each do
    @piece = ChessPiece.new('♟', 'd1', :blue, 'chess player',
                            %i[two_spaces_forward one_space_forward diagonal_to_take])
  end

  context '#owner' do
    it 'returns owner from initialization' do
      expect(@piece.owner).to eq('chess player')
    end
  end

  context '#start_pos' do
    it 'returns starting position from initialization' do
      expect(@piece.start_pos).to eq('d1')
    end
  end

  context '#curr_pos' do
    it 'returns starting location when unchanged' do
      expect(@piece.curr_pos).to eq('d1')
    end
  end

  it 'returns new location after it is changed' do
    @piece.curr_pos = 'e1'
    expect(@piece.curr_pos).to eq('e1')
  end
end

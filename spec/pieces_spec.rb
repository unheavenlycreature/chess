# frozen_string_literal: true

require './lib/pieces'

describe ChessPiece do
  before :all do
    @piece = ChessPiece.new('♕', :d1, 'chess player')
  end
  context '#owner' do
    it 'returns owner from initialization' do
      expect(@piece.owner).to eq('chess player')
    end
  end

  context '#starting_location' do
    it 'returns starting location from initialization' do
      expect(@piece.starting_location).to eq(:d1)
    end
  end

  context '#to_s' do
    it 'represents itself using the glyph from initialization' do
      expect(@piece.to_s).to eq('♕')
    end
  end
end

# frozen_string_literal: true

require './lib/board'

describe ChessBoard do
  context 'ChessBoard#position_to_coordinates' do
    it 'maps a1 to [0, 0]' do
      expect(ChessBoard.position_to_coordinates('a1')).to eq([0, 0])
    end

    it 'maps h8 to [7, 7]' do
      expect(ChessBoard.position_to_coordinates('h8')).to eq([7, 7])
    end
  end
end

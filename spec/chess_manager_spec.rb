# frozen_string_literal: true

require './lib/chess_manager'
require './lib/pieces'

describe ChessManager do
  before :each do
    allow($stdout).to receive :write
  end

  context '#play' do
    context 'end game' do
      it 'identifies checkmate' do
        expectation = expect do
          ChessManager.new(
            'loser',
            'winner',
            [King.new('a8', :light_white, 'loser')],
            [King.new('a1', :blue, 'winner'), Queen.new('c7', :blue, 'winner')]
          ).play
        end
        expectation.to output(/Checkmate/).to_stdout
      end

      context 'insufficient materials' do
        it 'identifies only kings' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white')],
              [King.new('a1', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Insufficient/).to_stdout
        end

        it 'identifies kings and knights' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white')],
              [King.new('a1', :blue, 'blue'), Knight.new('a2', :blue, 'blue'), Knight.new('a3', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Insufficient/).to_stdout
        end

        it 'identifies kings and single bishop' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white')],
              [King.new('a1', :blue, 'blue'), Bishop.new('b1', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Insufficient/).to_stdout
        end

        it 'identifies kings and white square bishops' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white'), Bishop.new('c8', :light_white, 'white')],
              [King.new('a1', :blue, 'blue'), Bishop.new('f1', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Insufficient/).to_stdout
        end

        it 'identifies kings and black square bishops' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white'), Bishop.new('c1', :light_white, 'white')],
              [King.new('a1', :blue, 'blue'), Bishop.new('f8', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Insufficient/).to_stdout
        end
      end

      context 'stalemate' do
        it 'identifies stalemate' do
          expectation = expect do
            ChessManager.new(
              'white',
              'blue',
              [King.new('a8', :light_white, 'white')],
              [King.new('a1', :blue, 'blue'), Pawn.new('a7', :blue, 'blue')]
            ).play
          end
          expectation.to output(/Stalemate/).to_stdout
        end
      end
    end
  end
end

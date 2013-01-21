require 'rspec'
require './chess.rb'

def build_sample
  sample = Array.new(8) {Array.new(8)}
  sample[0][0] = King.new(0, 0, 0)
  sample[7][7] = King.new(7, 7, 1)
  sample[1][7] = BlackPawn.new(1, 7)
  sample[0][4] = Rook.new(0, 4, 1)
  sample[4][0] = Rook.new(4, 0, 1)
  sample[4][4] = Bishop.new(4, 4, 1)
  sample
end


describe Chess do 
	subject(:game) {Chess.new}

	describe "#Initialize" do
		subject(:game) {Chess.new("test_board")}

		it 'allows a custom board to be passed in' do
			game.board.should == "test_board"
		end
	end
end

describe Chess do
	subject(:game) {Chess.new(build_sample)}

	let(:player1) { game.create_player("ned", 1) }
	let(:player2) { game.create_player("kush", 2) }

	before(:all) do 
		game.assign_pieces(player1)
		game.assign_pieces(player2)
	end

	describe '#create_player' do
		subject(:player) {game.create_player("Kriti", 1)}

		it 'creates a new player with assigned name' do
			player.name.should == "Kriti"
		end

		it 'creates a new player with assigned number' do
			player.num.should == 1
		end
	end

	describe '#move_piece' do
		let(:moving_piece) { double(game.board[0, 4])}
		let(:killed_piece) { double(game.board[0, 0])}

		before(:all) do 
			game.move_piece([0, 4], [0, 0])
		end

		#I need to refactor how my piece's players get assigned
		it 'sets the from square to nil' do
			p moving_piece
			game.board[0][4].should == nil
		end

		it 'puts the piece on the to square' do
			game.board[0, 0].should == moving_piece
		end

		it 'deletes the killed piece from its players pieces'
	end
end

describe HumanPlayer do
	subject(:player) {HumanPlayer.new("ned", 1)}
end

describe Piece do
end

describe Knight do
end

describe Rook do
end

describe Bishop do
end

describe King do
end

describe Queen do
end

describe WhitePawn do
	subject(:pawn) {WhitePawn.new(6, 7)}

	its(:name) { should == "\u2659" }
	its(:pos) { should == [6, 7]}
	its(:color) { should == "W"}
end

describe BlackPawn do
	subject(:pawn) {BlackPawn.new(1, 7)}
end



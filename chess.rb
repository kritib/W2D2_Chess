class Chess
  def initialize
    @board = initialize_board
  end

  def play
    puts "Welcome to Command-Line-Chess!"
    set_players

    [@player1, @player2].each do |player|
      print_board
      from, to = get_move(player)
      until valid_move?(from, to, player)
        from, to = get_move(player)
      end
    end
  end




  def initialize_board
    board = Array.new(8) {Array.new(8)}
    populate_board(board)
  end


  def populate_board(board)
    [0, 7].each do |row|
      4.times do |col|
        board[row][col] = create_piece(row, col)
        board[row][(7-col)] = create_piece(row, (7-col))
      end
    end
    8.times do |col|
      board[1][col] = Pawn.new([1, col])
      board[6][col] = Pawn.new([6, col])
    end
    board
  end


  def create_piece(row, col)
    if col == 0 || col == 7
      return Rook.new([row, col])
    elsif col == 1 || col == 6
      return Knight.new([row, col])
    elsif col == 2 || col == 5
      return Bishop.new([row, col])
    elsif [row, col] == [0, 3] || [row, col] == [7, 4]
      return King.new([row, col])
    else
      return Queen.new([row, col])
    end
  end

  def print_board
    puts "   #{("e".."h").to_a.join(" ")}"
    @board.each_with_index do |row, i|
      print "#{(8-i)} |"
      row.each do |piece|
        if piece.nil?
          print " |"
        else
          print "#{piece.name}|"
        end
      end
      puts " #{(8-i)}"
    end
    puts "   #{("e".."h").to_a.join(" ")}"
  end

  def set_players
    print "Enter name of Player 1 (white): "
    @player1 = create_player(gets.chomp, 6)
    print "Enter name of Player 2 (black): "
    @player2 = create_player(gets.chomp, 0)
  end

  def create_player(name, row)
    if name.downcase == "computer"
      player = ComputerPlayer.new
    else
      player = HumanPlayer.new(name)
    end
    assign_pieces(player)
    player
  end

  def assign_pieces(player)
    [row, row+1].each do |i|
      board[i].each do |piece|
        player.pieces << piece
        piece.player = player
      end
    end
  end

  def get_move(player)
    move = []
    until valid_input?(move)
      puts "#{player.name}, make your move (e.g. e2 e4):"
      move = gets.chomp.downcase.split
    end
    return parse_move(move)
  end

  def valid_input?(move)
    if move.length == 2
      return move.all? do |pos| 
        pos.length == 2 && ("a".."h").include?(pos[0]) && ("1".."8").include?(pos[1])
      end
    end
    false
  end

  def parse_move(move)
    from = [(move[0][1].to_i), (("a".."h").to_a.index(move[0][0]))]
    to = [(move[1][1].to_i), (("a".."h").to_a.index(move[1][0]))]
    [from, to]
  end

  def valid_move?
  end


end

class HumanPlayer
  attr_accessor :pieces
  attr_reader :name

  def initialize(name)
    @name = name
  end

end

class Piece
  attr_accessor :player
  attr_reader :name

  def initialize(name, pos)
    @name = name
    @pos = pos
  end
end


class Knight < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("N", pos)
  end
end

class Rook < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("R", pos)
  end
end

class Bishop < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("B", pos)
  end
end

class King < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("K", pos)
  end
end

class Queen < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("Q", pos)
  end
end

class Pawn < Piece
  def initialize(pos)
    @moves = [[1, 2], [2, 1]]
    super("P", pos)
  end
end




game = Chess.new
game.play



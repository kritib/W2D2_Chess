class Chess
  def initialize
    @board = initialize_board
  end

  def play
    puts "Welcome to Command-Line-Chess!"
    set_players

    while true
      [@player1, @player2].each do |player|
        print_board
        from, to = player.get_move
        until valid_move?(from, to, player)
          from, to = player.get_move
        end
        make_move(from, to, player)
      end
    end

    print_board
  end

  def make_move(from, to, player)
    piece = @board[from[0]][from[1]]
    @board[from[0]][from[1]] = nil
    @board[to[0]][to[1]] = piece
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
      board[1][col] = BlackPawn.new
      board[6][col] = WhitePawn.new
    end
    board
  end


  def create_piece(row, col)
    if col == 0 || col == 7
      return Rook.new(row)
    elsif col == 1 || col == 6
      return Knight.new(row)
    elsif col == 2 || col == 5
      return Bishop.new(row)
    elsif col == 4
      return King.new(row)
    else
      return Queen.new(row)
    end
  end

  def print_board
    puts "   #{("a".."h").to_a.join(" ")}"
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
    puts "   #{("a".."h").to_a.join(" ")}"
  end

  def set_players
    print "Enter name of Player 1 (white): "
    @player1 = create_player(gets.chomp, 1, 6)
    print "Enter name of Player 2 (black): "
    @player2 = create_player(gets.chomp, 2, 0)
  end

  def create_player(name, num, row)
    if name.downcase == "computer"
      player = ComputerPlayer.new(num)
    else
      player = HumanPlayer.new(name, num)
    end
    assign_pieces(player, row)
    player
  end

  def assign_pieces(player, row)
    [row, row+1].each do |i|
      @board[i].each do |piece|
        player.pieces << piece
        piece.player = player
      end
    end
  end

  

  def valid_move?(from, to, player)
    if piece = player_piece?(from, player)
      unless player_piece?(to, player)
        return true if piece.valid_dest?(from, to, @board)
      end
    end
    puts "Invalid Move"
    false
  end

  def player_piece?(square, player)
    piece = @board[square[0]][square[1]]
    unless piece.nil?
      if piece.player == player
        return piece
      end
    end
    nil
  end


end

class HumanPlayer
  attr_accessor :pieces
  attr_reader :name, :num

  def initialize(name, num)
    @name = name
    @num = num
    @pieces = []
  end


  def get_move
    puts "#{@name}, make your move (e.g. e2 e4):"
    move = gets.chomp.downcase.split
    until valid_input?(move)
      puts "#{@name}, make your move (e.g. e2 e4):"
      move = gets.chomp.downcase.split
    end
    return parse_move(move)
  end

  def valid_input?(move)
    if move.length == 2
      return true if move.all? do |pos| 
        pos.length == 2 && ("a".."h").include?(pos[0]) && ("1".."8").include?(pos[1])
      end
    end
    puts "Invalid input"
    false
  end

  def parse_move(move)
    from = [(8-(move[0][1].to_i)), (("a".."h").to_a.index(move[0][0]))]
    to = [(8-(move[1][1].to_i)), (("a".."h").to_a.index(move[1][0]))]
    [from, to]
  end

end

class Piece
  attr_accessor :player
  attr_reader :name

  def initialize
  end

  def valid_dest?(from, to, board)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - from[i])}
    if board[to[0]][to[1]] != nil
      return false unless @moves[:kill].include?(diff)
    elsif from[0] == @start_row
      return false unless @moves[:first].include?(diff)
    else
      return false unless @moves[:else] == diff
    end
    true 
  end

  def path_empty?(from, to, board)
    distance = 0
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - from[i])}
    diff.each {|num| distance = num.abs if num!= 0}
    starter = diff.map {|num| num/distance}
    path_square = from.dup
    distance.times do
      2.times  {|i| path_square[i] += starter[i]}
      return false unless board[path_square[0]][path_square[1]].nil?
    end
    true
  end

  def path_diff(from, to)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - from[i]).abs}
    diff
  end

end


class Knight < Piece
  def initialize(row)
    @moves = [[1, 2], [2, 1]]
    if row == 0
      @name = "\u265E"
    else
      @name = "\u2658"
    end
  end

  def valid_dest?(from, to, board)
    diff = path_diff(from, to)
    @moves.include?(diff)
  end
end

class Rook < Piece
  def initialize(row)
    if row == 0
      @name = "\u265C"
    else
      @name = "\u2656"
    end
  end

  def valid_dest?(from, to, board)
    diff = path_diff(from, to)
    if diff.count(0) == 1
      return true if path_empty?(from, to, board)
    end
    false
  end

end

class Bishop < Piece
  def initialize(row)
    if row == 0
      @name = "\u265D"
    else
      @name = "\u2657"
    end
  end

  def valid_dest?(from, to, board)
    diff = path_diff(from, to)
    if diff[0] == diff[1]
      return true if path_empty?(from, to, board)
    end
    false
  end

end

class King < Piece
  def initialize(row)
    @moves = [[1, 0], [0, 1], [1, 1]]
    if row == 0
      @name = "\u265A"
    else
      @name = "\u2654"
    end
  end

  def valid_dest?(from, to, board)
    diff = path_diff(from, to)
    @moves.include?(diff)
  end

end

class Queen < Piece
  def initialize(row)
    if row == 0
      @name = "\u265B"
    else
      @name = "\u2655"
    end
  end

  def valid_dest?(from, to, board)
    diff = path_diff(from, to)
    if diff.count(0) == 1 || diff[0] == diff[1]
      return true if path_empty?(from, to, board)
    end
    false
  end

end

class WhitePawn < Piece
  def initialize
    @moves = {:kill => [[-1, 1], [-1, -1]],
              :first => [[-2, 0], [-1, 0]],
              :else => [-1, 0]}

    @name = "\u2659"
    @start_row = 6
  end
end


class BlackPawn < Piece
  def initialize
    @moves = {:kill => [[1, 1], [1, -1]],
              :first => [[2, 0], [1, 0]],
              :else => [1, 0]}
    @name = "\u265F"
    @start_row = 1
  end
end



game = Chess.new
game.play



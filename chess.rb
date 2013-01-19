class Chess
  attr_reader :board

  def initialize(board = nil)
    if board.nil?
      @board = initialize_board
    else
      @board = board
    end
  end

  def play
    puts "Welcome to Command-Line-Chess!"
    @players = set_players

    while true
      @players.each do |player|
        print_board
        while true 
          from, to = player.get_move
          break if valid_move?(from, to, player)
          puts "Invalid move"
        end
        make_move(from, to, player)
        king = find_opp_king(player)
        if danger_zone = check?(king.pos, player)
          if zone_protected?(danger_zone, king.player)
            puts "CHECK!"
          elsif checkmate?(king, player)
            puts "CHECKMATE"
          else
            puts "CHECK!"
          end
          
        end
      end
    end

    print_board
  end

  def checkmate?(king, player)
    true unless king.destinations(@board).any? do |king_pos|
      if danger_zone = check?(king_pos, player)
        zone_protected?(danger_zone, king.player)
      else
        false
      end
    end
  end

  def zone_protected?(danger_zone, player)
    path = danger_zone.pop
    path.each do |square|
      player.pieces.each do |piece|
        if piece.valid_dest?(square, @board)
          if danger_zone.empty?
            return true
          end
          return true if danger_zone.all? do |path|
            path.include?(square)
          end
        end
      end
    end
    false
  end

  def find_opp_king(player)
     @board.each do |row|
      row.each do |piece|
        return piece if piece.is_a?(King) && piece.player != player
      end
    end
    nil
  end


  def check?(king_pos, player)
    danger_zone = []
    player.pieces.each do |piece|
      if path = piece.valid_dest?(king_pos, @board)
        danger_zone << path
      end
    end
    danger_zone.empty? ? false : danger_zone
  end

  def make_move(from, to, player)
    piece = @board[from[0]][from[1]]
    dest_piece = @board[to[0]][to[1]]
    delete_piece(dest_piece) unless dest_piece.nil?
    @board[from[0]][from[1]] = nil
    @board[to[0]][to[1]] = piece
    piece.pos = [to[0], to[1]]
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
      board[1][col] = BlackPawn.new(1, col)
      board[6][col] = WhitePawn.new(6, col)
    end
    board
  end


  def create_piece(row, col)
    if col == 0 || col == 7
      return Rook.new(row, col, row)
    elsif col == 1 || col == 6
      return Knight.new(row, col, row)
    elsif col == 2 || col == 5
      return Bishop.new(row, col, row)
    elsif col == 4
      return King.new(row, col, row)
    else
      return Queen.new(row, col, row)
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
    player1 = create_player(gets.chomp, 1)
    assign_pieces(player1)

    print "Enter name of Player 2 (black): "
    player2 = create_player(gets.chomp, 2)
    assign_pieces(player2)

    [player1, player2]
  end

  def create_player(name, num)
    if name.downcase == "computer"
      player = ComputerPlayer.new(num)
    else
      player = HumanPlayer.new(name, num)
    end
  end

  
  def assign_pieces(player)
    if player.num == 1
      piece_color = "W"
    else
      piece_color = "B"
    end
    @board.each do |row|
      row.each do |piece|
        if !piece.nil?
          if piece.color == piece_color
            player.pieces << piece
            piece.player = player
          end
        end
      end
    end    
  end

  # def assign_pieces(player, row)
  #   [row, row+1].each do |i|
  #     @board[i].each do |piece|
  #       player.pieces << piece
  #       piece.player = player
  #     end
  #   end
  # end


  def valid_move?(from, to, player)
    if piece = player_piece?(from, player)
      unless player_piece?(to, player)
        return piece.valid_dest?(to, @board)
      end
    end
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

  def delete_piece(piece)
    piece.player.pieces.delete(piece)
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
    while true
      puts "#{@name}, make your move (e.g. e2 e4):"
      move = gets.chomp.downcase.split
      break if valid_input?(move)
      puts "Invalid input"
    end
    return parse_move(move)
  end

  def valid_input?(move)
    if move.length == 2
      return move.all? do |pos| 
        if pos.length == 2 
          return ("a".."h").include?(pos[0]) && ("1".."8").include?(pos[1])
        end
        false
      end
    end
    false
  end

  def parse_move(move)
    from = [(8-(move[0][1].to_i)), (("a".."h").to_a.index(move[0][0]))]
    to = [(8-(move[1][1].to_i)), (("a".."h").to_a.index(move[1][0]))]
    [from, to]
  end

end

class Piece
  attr_accessor :player, :pos
  attr_reader :name, :color

  def initialize(pos, color)
    if color == 0
      @color = "B"
    else
      @color = "W"
    end
    @pos = pos
  end

  def valid_dest?(to, board)
    diff = path_diff(to)
    if board[to[0]][to[1]] != nil
      return false unless @moves[:kill].include?(diff)
    elsif @pos[0] == @start_row
      return false unless @moves[:first].include?(diff)
    else
      return false unless @moves[:else] == diff
    end
    [[@pos]] 
  end

  def path_empty?(diff, board)
    distance = 0
    path = []

    diff.each {|num| distance = num.abs if num!= 0}
    starter = diff.map {|num| num/distance}
    path_square = @pos.dup
    distance.times do |dist|
      path << path_square.dup
      unless dist == 0
        return false unless board[path_square[0]][path_square[1]].nil?
      end
      2.times  {|i| path_square[i] += starter[i]}
    end
    path
  end

  def path_diff(to)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - @pos[i])}
    diff
  end

end


class Knight < Piece
  def initialize(row, col, color)
    @moves = [[1, 2], [2, 1]]
    if color == 0
      @name = "\u265E"
    else
      @name = "\u2658"
    end
    super([row, col], color)
  end

  def valid_dest?(to, board)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - @pos[i]).abs}
    diff
    return false unless @moves.include?(diff)
    [[@pos]]
  end
end

class Rook < Piece
  def initialize(row, col, color)
    if color == 0
      @name = "\u265C"
    else
      @name = "\u2656"
    end
    super([row, col], color)
  end

  def valid_dest?(to, board)
    diff = path_diff(to)
    if diff.count(0) == 1
      return path_empty?(diff, board)
    end
    false
  end

end

class Bishop < Piece
  def initialize(row, col, color)
    if color == 0
      @name = "\u265D"
    else
      @name = "\u2657"
    end
    super([row, col], color)
  end

  def valid_dest?(to, board)
    diff = path_diff(to)
    if diff[0] == diff[1] || diff[0] == (-diff[1])
      return path_empty?(diff, board)
    end
    false
  end

end

class King < Piece
  def initialize(row, col, color)
    @moves = [[1, 0], [0, 1], [1, 1], [-1, 0], [0, -1], [-1, -1]]
    if color == 0
      @name = "\u265A"
    else
      @name = "\u2654"
    end
    super([row, col], color)
  end

  def valid_dest?(to, board)
    diff = path_diff(to)
    return false unless @moves.include?(diff)
    [[@pos]]
  end

  def destinations(board)
     dest_array = @moves.select do |move|
      move = [move[0] + @pos[0], move[1] + @pos[1]]
      move.all? {|i| (0..7).include?(i)}
    end

    dest_array = dest_array.select do |pos|
      piece = board[pos[0]][pos[1]]
      piece.nil? || piece.player != king.player
    end          
  end

end

class Queen < Piece
  def initialize(row, col, color)
    if color == 0
      @name = "\u265B"
    else
      @name = "\u2655"
    end
    super([row, col], color)
  end

  def valid_dest?(to, board)
    diff = path_diff(to)
    if diff.count(0) == 1 || diff[0] == diff[1]
      return true if path_empty?(diff, board)
    end
    false
  end

end

class WhitePawn < Piece
  def initialize(row, col)
    @moves = {:kill => [[-1, 1], [-1, -1]],
              :first => [[-2, 0], [-1, 0]],
              :else => [-1, 0]}

    @name = "\u2659"
    @start_row = 6
    super([row, col], 1)
  end
end


class BlackPawn < Piece
  def initialize(row, col)
    @moves = {:kill => [[1, 1], [1, -1]],
              :first => [[2, 0], [1, 0]],
              :else => [1, 0]}
    @name = "\u265F"
    @start_row = 1
    super([row, col], 0)
  end
end



def build_sample
  sample = Array.new(8) {Array.new(8)}
  sample[0][0] = King.new(0, 0, 0)
  sample[0][4] = Rook.new(0, 4, 1)
  sample[4][0] = Rook.new(4, 0, 1)
  sample[4][4] = Bishop.new(4, 4, 1)
  sample
end

game = Chess.new(build_sample)
game.play



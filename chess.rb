class Chess
  attr_reader :board

  def initialize(board = nil)
    if board.nil?
      @board = initialize_board
    else
      @board = board
    end
  end

  #GAME PLAY METHODS

  #Master method that runs the game
  def run
    puts "Welcome to Command-Line-Chess!"
    @players = set_players

    winner = play_game
    
    print_board
    puts "Congratulations #{winner.name}! You have won the game."
  end

  #Returns players for the new chess game
  def set_players
    print "Enter name of Player 1 (white): "
    player1 = create_player(gets.chomp, 1)
    assign_pieces(player1)

    print "Enter name of Player 2 (black): "
    player2 = create_player(gets.chomp, 2)
    assign_pieces(player2)

    [player1, player2]
  end

  #Creates either a human player or a computer player
  #Computer player has not been built yet
  def create_player(name, num)
    if name.downcase == "computer"
      player = ComputerPlayer.new(num)
    else
      player = HumanPlayer.new(name, num)
    end
  end

  #Assigns all the white (W) pieces to player 1 and the rest to player 2  
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


  #runs the game loop
  #returns the winning player
  def play_game
    while true
      @players.each do |player|
        print_board
        make_move(player)

        king = find_opp_king(player)
        return player if king.nil? || game_won?(king, player)  
      end
    end
  end

  #Makes a valid move for player
  def make_move(player)
    while true 
      from, to = player.get_move
      break if valid_move?(from, to, player)
      puts "Invalid move"
    end
    move_piece(from, to)
  end

  #Moves the piece from 'from' to 'to'
  #updates piece.pos for moved piece and deletes killed piece(if any) 
  def move_piece(from, to)
    piece = @board[from[0]][from[1]]
    dest_piece = @board[to[0]][to[1]]

    dest_piece.player.pieces.delete(dest_piece) unless dest_piece.nil?
    @board[from[0]][from[1]] = nil
    @board[to[0]][to[1]] = piece
    
    piece.pos = [to[0], to[1]]
  end

  def find_opp_king(player)
     @board.each do |row|
      row.each do |piece|
        return piece if piece.is_a?(King) && piece.player != player
      end
    end
    nil
  end

  #BOARD METHODS

  #returns a chess board with all pieces in regular starting pos
  def initialize_board
    board = Array.new(8) {Array.new(8)}
    populate_board(board)
  end

  #fills in the board with pieces in starting position
  def populate_board(board)
    #Fills in the top and bottom rows
    [0, 7].each do |row|
      4.times do |col|
        board[row][col] = create_piece(row, col)
        board[row][(7-col)] = create_piece(row, (7-col))
      end
    end

    #Fills in the pawns
    8.times do |col|
      board[1][col] = BlackPawn.new(1, col)
      board[6][col] = WhitePawn.new(6, col)
    end

    board
  end

  #Creates all the pieces (except pawns) for game setup
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

  #Prints the board
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

  #VALIDATION METHODS

  #Returns true if piece at 'from' is the players piece
  #and the piece at 'to' is NOT the player's piece
  #and 'to' is a valid destination for the piece at 'from'
  def valid_move?(from, to, player)
    if piece = player_piece?(from, player)
      unless player_piece?(to, player)
        return piece.valid_dest?(to, @board)
      end
    end
    false
  end

  #returns piece 
  def player_piece?(square, player)
    piece = @board[square[0]][square[1]]
    unless piece.nil?
      if piece.player == player
        return piece
      end
    end
    nil
  end

  #Returns true if player has won the game
  #Puts check/checkmate status of the players opponent
  def game_won?(king, player)
    if danger_zone = check?(king.pos, player)

      if zone_protected?(danger_zone, king.player)
        puts "CHECK!"
      elsif checkmate?(king, player)
        puts "CHECKMATE!"
        return true
      else
        puts "CHECK!"
      end  
    end

    false
  end

  #Returns the danger zone if the opponents king is in check at that position
  #The danger zone is an array of the paths of all the players pieces
  #that can kill the opponents king in one move
  #Else returns false
  def check?(king_pos, player)
    danger_zone = []

    player.pieces.each do |piece|
      if path = piece.valid_dest?(king_pos, @board)
        danger_zone << path
      end
    end

    danger_zone.empty? ? false : danger_zone
  end

  #returns true if the opponent(player in this case) can protect his king
  #by moving any of his other pieces
  def zone_protected?(danger_zone, player)
    path = danger_zone.pop
    
    #checks for one path. If protected, makes sure that that single move
    #protects the king from every other path in the danger zone as well
    path.each do |square|
      player.pieces.each do |piece|
        
        if piece.valid_dest?(square, @board)
          return true if danger_zone.empty?
          return true if danger_zone.all? do |path|
            path.include?(square)
          end
        end
      end
    end
    false
  end

  #Returns true if all of the kings destinations are in check
  def checkmate?(king, player)
    king.destinations(@board).all? do |king_pos|
      check?(king_pos, player) 
    end
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

  #keeps asking the player for his move until he enters valid input
  #Returns the players move
  def get_move
    while true
      print "#{@name}, make your move (e.g. e2 e4): "
      move = gets.chomp.downcase.split
      break if valid_input?(move)
      puts "Invalid input"
    end
    return parse_move(move)
  end

  #returns false unless the player has entered a valid combination of
  #letters and words to signify a move
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

  #returns players input converted into coordinates on the board
  def parse_move(move)
    #Is this enough of a repetition for me to iterate? It seemed more
    #tedious for me to iterate in this situation
    from = [(8-(move[0][1].to_i)), (("a".."h").to_a.index(move[0][0]))]
    to = [(8-(move[1][1].to_i)), (("a".."h").to_a.index(move[1][0]))]
    [from, to]
  end
end


class Piece
  attr_accessor :player, :pos
  attr_reader :name, :color

  #Assigns the piece's color and initial position on the board
  def initialize(pos, color)
    if color == 0
      @color = "B"
    else
      @color = "W"
    end
    @pos = pos
  end

  #Used only by WhitePawn and BlackPawn.
  #Returns false if destination is invalid for that piece
  #Returns path (in this case, starting position) if move is valid
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

  #Checks each square on the board of the pieces path for the move
  #returns the path if path is empty, else returns false 
  def path_empty?(diff, board)
    distance = 0
    path = []

    #gets the distance between from and to
    diff.each {|num| distance = num.abs if num!= 0}
    #gets the coordinate change for each step along the path
    step = diff.map {|num| num/distance}
    path_square = @pos.dup
    
    distance.times do |dist|
      path << path_square.dup
      
      unless dist == 0
        return false unless board[path_square[0]][path_square[1]].nil?
      end
      #moves path_square one step along the path
      2.times  {|i| path_square[i] += step[i]}
    end
    
    path
  end

  #returns the difference between the destination and current position
  def path_diff(to)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - @pos[i])}
    diff
  end
end


class Knight < Piece
  
  #Assigns the piece's name and potential moves. calls super for rest.
  def initialize(row, col, color)
    @moves = [[1, 2], [2, 1]]
    
    if color == 0
      @name = "\u265E"
    else
      @name = "\u2658"
    end

    super([row, col], color)
  end

  #Returns false if destination is invalid for that piece
  #Returns path (in this case, starting position) if move is valid
  def valid_dest?(to, board)
    diff = [0, 0]
    2.times {|i| diff[i] = (to[i] - @pos[i]).abs}
    diff

    return false unless @moves.include?(diff)
    [[@pos]]
  end
end

class Rook < Piece
  
  #Assigns the piece's name. calls super for rest.
  def initialize(row, col, color)
    if color == 0
      @name = "\u265C"
    else
      @name = "\u2656"
    end
    super([row, col], color)
  end

  #Returns false if destination is invalid for that piece
  #Returns path if move is valid
  def valid_dest?(to, board)
    diff = path_diff(to)
    if diff.count(0) == 1
      return path_empty?(diff, board)
    end
    false
  end
end

class Bishop < Piece

  #Assigns the piece's name. calls super for rest.
  def initialize(row, col, color)
    if color == 0
      @name = "\u265D"
    else
      @name = "\u2657"
    end

    super([row, col], color)
  end

  #Returns false if destination is invalid for that piece
  #Returns path if move is valid
  def valid_dest?(to, board)
    diff = path_diff(to)

    if diff[0] == diff[1] || diff[0] == (-diff[1])
      return path_empty?(diff, board)
    end
    false
  end
end

class King < Piece

  #Assigns the piece's name and potential moves. calls super for rest.
  def initialize(row, col, color)
    @moves = [[1, 0], [0, 1], [1, 1], [-1, 0], [0, -1], [-1, -1], [1, -1], [-1, 1]]
    
    if color == 0
      @name = "\u265A"
    else
      @name = "\u2654"
    end

    super([row, col], color)
  end

  #Returns false if destination is invalid for that piece
  #Returns path (in this case, starting position) if move is valid
  def valid_dest?(to, board)
    diff = path_diff(to)
    return false unless @moves.include?(diff)
    [[@pos]]
  end

  #Returns an array of the kings potential destinations on the current board
  def destinations(board)
    #selects destinations that are on the board
     dest_array = @moves.select do |move|
      move = [move[0] + @pos[0], move[1] + @pos[1]]
      move.all? {|i| (0..7).include?(i)}
    end

    #selects only destinations that are empty or have the opponents piece on it
    dest_array = dest_array.select do |pos|
      piece = board[pos[0]][pos[1]]
      piece.nil? || piece.player != @player
    end          
  end

end

class Queen < Piece

  #Assigns the piece's name. calls super for rest.
  def initialize(row, col, color)
    if color == 0
      @name = "\u265B"
    else
      @name = "\u2655"
    end

    super([row, col], color)
  end

  #Returns false if destination is invalid for that piece
  #Returns path if move is valid
  def valid_dest?(to, board)
    diff = path_diff(to)

    if diff.count(0) == 1 || diff[0] == diff[1]
      return path_empty?(diff, board)
    end

    false
  end

end

class WhitePawn < Piece

  #Assigns the piece's name and potential moves. calls super for rest.
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

  #Assigns the piece's name and potential moves. calls super for rest.
  def initialize(row, col)
    @moves = {:kill => [[1, 1], [1, -1]],
              :first => [[2, 0], [1, 0]],
              :else => [1, 0]}

    @name = "\u265F"
    @start_row = 1

    super([row, col], 0)
  end
end



#Sample board for testing
def build_sample
  sample = Array.new(8) {Array.new(8)}
  sample[0][0] = King.new(0, 0, 0)
  sample[7][7] = King.new(7, 7, 1)
  sample[0][4] = Rook.new(0, 4, 1)
  sample[4][0] = Rook.new(4, 0, 1)
  sample[4][4] = Bishop.new(4, 4, 1)
  sample
end



def play_chess(filename = nil)
  if filename.nil?
    game = Chess.new
  else
    string = File.read(filename).chomp
    game = YAML::load(string)
  end
end



#Pass in build_sample to test check/checkmate/game end
# game = Chess.new
# game.run



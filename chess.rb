class Chess
  def initialize
    @board = initialize_board
  end

  def play
    print_board
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
    puts "   #{("A".."H").to_a.join(" ")}"
    @board.each_with_index do |row, i|
      print "#{(i+1)} |"
      row.each do |piece|
        if piece.nil?
          print " |"
        else
          print "#{piece.name}|"
        end
      end
      puts
    end
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



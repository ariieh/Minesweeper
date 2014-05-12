class Minesweeper
  
  def initialize
    @board = Board.new
  end
  
  def play
    @board.print_board
    command, x, y = get_input
  end
  
  def get_input
    move = []
    
    begin
      puts "Enter a move: (r/f,x,y)"
      input = gets.chomp.downcase.split(",")
      if input.count != 3
        raise "Wrong number of inputs!"
      elsif input[0] != "r" && input[0] != "f"
        raise "Wrong action!"
      elsif !input[1].to_i.between?(1,Board::BOARD_SIDE_LENGTH)
        raise "Invalid x coordinate!"
      elsif !input[2].to_i.between?(1,Board::BOARD_SIDE_LENGTH)
        raise "Invalid y coordinate!"
      else
        input[1..2].map!(&:to_i)
        input
      end
    rescue StandardError => error
      puts error.message
      retry
    end
  end
  
end

class Board
  NUM_MINES = 10
  BOARD_SIDE_LENGTH = 9
  
  def initialize
    elements = Array.new(NUM_MINES, :mine) 
    elements += Array.new(BOARD_SIDE_LENGTH**2 - NUM_MINES)
    elements.shuffle!
    
    @board = Array.new(BOARD_SIDE_LENGTH){ Array.new(BOARD_SIDE_LENGTH) }
    @board.each_index do |row|
      @board[row].each_index do |col|
        @board[row][col] = Tile.new(elements.pop)
      end
    end
  end
  
  def print_board
    @board.each_index do |row|
      @board[row].each_index do |col|
        @board[row][col].print_tile
        print ' '
      end
      puts
    end
  end
  
end

class Tile
  def initialize(value)
    @value = value
  end
  
  def print_tile
    case @value
    when nil
      print '*'
    when :mine
      print '!'
    end
  end
  
end
class Minesweeper
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

board = Board.new
board.print_board
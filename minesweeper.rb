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
    @board.each do |row|
      @board.each do |col|
        @board[row][col] = Tile.new(elements.pop)
      end
    end
  end
end

class Tile
  def initialize(value)
    @value = value
  end
end
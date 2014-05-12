class Minesweeper
  
  def initialize
    @board = Board.new
  end
  
  def play
    @board.print_board
    command, x, y = get_input
    make_move(command, [x - 1, y - 1])
  end
  
  def make_move(command, move)
    if command == "f"
      @board[*move].flag!
    else # command == 'r'
      @board.uncover(move)
    end
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
    
    @board.each_index do |row|
      @board[row].each_index do |col|
        
        neighbors = surrounding_tiles([row, col]).map{|x, y| self[x, y]}
        nearby_mines = neighbors.select { |tile| tile.value == :mine }.count
        @board[row][col].num_mines = nearby_mines
        
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
    
    nil
  end
  
  def [](x,y)
    @board[x][y]
  end
  
  def surrounding_tiles(pos)
    x, y = pos
    [[x + 1, y + 1], [x + 1, y], [x + 1, y - 1],
    [x - 1, y + 1], [x - 1, y], [x - 1, y - 1],
    [x, y + 1], [x, y], [x, y - 1]].select do |x, y| 
      x.between?(0, Board::BOARD_SIDE_LENGTH - 1) &&
      y.between?(0, Board::BOARD_SIDE_LENGTH - 1)
    end
  end
  
  def uncover(move)
    queue = [move]
    until queue.empty?
      move = queue.shift
      tile = self[*move]
      tile.reveal!
      neighbors = surrounding_tiles(move)
      if neighbors.map{|x, y| self[x, y]}.none? { |tile| tile.value == :mine }
        queue += neighbors.reject{ |tile| tile.revealed? }
      end
    end
  end
end

class Tile
  attr_reader :value
  attr_accessor :num_mines
  
  def initialize(value)
    @value = value
    @flagged = false
    @revealed = false
    @num_mines = nil
  end
  
  
  
  def revealed?
    @revealed
  end
  
  def flag!
    @flagged = @flagged ? false : true
  end
  
  def reveal!
    @revealed = true unless @flagged
  end
  
  def print_tile
    if @flagged
      print 'F'
    elsif !@revealed
      print '*'
    else
      case @value
      when nil
        print '_'
      when :mine
        print '!'
      end
    end
  end
  
end

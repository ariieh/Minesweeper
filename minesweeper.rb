class Minesweeper
  
  def initialize
    @board = Board.new
  end
  
  def play
    loop do
      @board.print_board
      command, x, y = get_input
      make_move(command, [x - 1, y - 1])

      if win?
        puts "You win!"
        break
      elsif lose?
        puts "You lose!"
        break
      end

    end

    @board.print_final_state
  end
  
  def make_move(command, move)
    if command == "f"
      @board[*move].flag!
    else # command == 'r'
      @board.uncover(move)
    end
  end
  
  def win?
    return true if @board.all? do |row, col|
      if @board[row, col].value == :mine
        @board[row, col].flagged?
      else
        !@board[row, col].flagged?
      end
    end
    false
  end
  
  def lose?
    return true if @board.any? do |row, col|
      @board[row, col].value == :mine && @board[row, col].revealed?
    end
    false
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
        input[1..2] = input[1..2].map(&:to_i)
        input
      end
    rescue StandardError => error
      puts error.message
      retry
    end
  end
  
end

class Board
  BOARD_SIDE_LENGTH = 4
  NUM_MINES = BOARD_SIDE_LENGTH**2/8
  
  def initialize
    @board = Array.new(BOARD_SIDE_LENGTH){ Array.new(BOARD_SIDE_LENGTH) }
    
    elements = Array.new(NUM_MINES, :mine) 
    elements.concat(Array.new(BOARD_SIDE_LENGTH**2 - NUM_MINES)).shuffle!
    
    setup_tiles(elements)
  end
  
  def setup_tiles(elements)
    each { |row, col| @board[row][col] = Tile.new(elements.pop) }
    each do |row, col|
      neighbors = surrounding_tiles([row, col]).map{|x, y| self[x, y]}
      nearby_mines = neighbors.select { |tile| tile.value == :mine }.count
      @board[row][col].num_mines = nearby_mines
    end
  end
  
  def each(&prc)
    @board.each_index do |row|
      @board[row].each_index do |col|
        prc.call(row, col)
      end
    end
    self
  end
  
  def any?(&prc)
    each do |row, col|
      return true if prc.call(row, col)
    end
    false
  end
  
  def all?(&prc)
    each do |row, col|
      return false unless prc.call(row, col)
    end
    true
  end
  
  def print_board
    puts '  ' + (1..BOARD_SIDE_LENGTH).to_a.join(" ")
    
    @board.each_index do |row|
      print (row + 1 ).to_s + ' '
      
      @board[row].each_index do |col|
        @board[row][col].print_tile
        print ' '
      end
      puts
    end
    
    nil
  end
  
  def print_final_state
   each do |row, col|
      self[row, col].flag! if self[row, col].flagged?
      self[row, col].reveal! 
    end.print_board
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
      self[*move].reveal!
      
      neighbors = surrounding_tiles(move)
      if neighbors.map{|x, y| self[x, y]}.none? { |tile| tile.value == :mine }
        queue += neighbors.reject{ |pos| self[*pos].revealed? }
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
    @num_mines = 0
  end
  
  def revealed?
    @revealed
  end
  
  def flagged?
    @flagged
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
    elsif @value == :mine
      print '!'
    else
      @num_mines == 0 ? (print '_') : (print @num_mines)
    end
  end
end

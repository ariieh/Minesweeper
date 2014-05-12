#encoding: utf-8
#colorize gem
#clear each time

require 'yaml'

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
        puts "You win!"; break
      elsif lose?
        puts "You lose!"; break
      end

    end

    @board.print_final_state
  end
  
  def make_move(command, move)
    command == "f" ? @board[*move].flag! : @board.uncover(move)
  end
  
  def win?
    @board.all? do |row, col|
      tile = @board[row, col]
      tile.value == :mine ? tile.flagged? : !tile.flagged?
    end
  end
  
  def lose?
    @board.any? do |row, col|
      @board[row, col].value == :mine && @board[row, col].revealed?
    end
  end
  
  def get_input
    move = []
    
    begin
      puts "Enter a move (r/f,x,y) or type save"
      input = gets.chomp.downcase.split(",")
      if input[0] == "save"
        save("minesweeper.yaml")
        abort("Game saved!")
      elsif input.count != 3
        raise "Wrong number of inputs!"
        
      elsif input[0] != "r" && input[0] != "f"
        raise "Wrong action!"
        
      elsif !input[1].to_i.between?(1, Board::BOARD_SIDE_LENGTH)
        raise "Invalid x coordinate!"
        
      elsif !input[2].to_i.between?(1, Board::BOARD_SIDE_LENGTH)
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
  
  def save(file_path)
    File.open(file_path, "w") do |f|
      f.puts to_yaml
    end
  end
  
  def self.load(file_path)
    YAML::load(File.read(file_path)).play
  end
end

class Board
  BOARD_SIDE_LENGTH = 9
  NUM_MINES = (BOARD_SIDE_LENGTH ** 2) / 8
  POSITION_DELTAS = [
    [1, 1], [1, 0], [1, -1],
    [0, 1], [0, 0], [0, -1],
    [-1, 1], [-1, 0], [-1, -1]
  ]
    
  def initialize
    @board = Array.new(BOARD_SIDE_LENGTH){ Array.new(BOARD_SIDE_LENGTH) }
    
    elements = Array.new(NUM_MINES, :mine) 
    elements.concat(Array.new(BOARD_SIDE_LENGTH ** 2 - NUM_MINES)).shuffle!
    
    setup_tiles(elements)
  end
  
  def setup_tiles(elements)
    each do |row, col| 
      @board[row][col] = Tile.new(elements.pop)
    end
    
    each do |row, col|
      
      nearby_mines = surrounding_tiles([row, col]).select do |tile| 
        tile.value == :mine
      end.count
      
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
  
  def each_tile(&prc)
    each { |row, col| prc.call(self[row, col]) }
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
   each_tile do |tile|
      tile.flag! if tile.flagged?
      tile.reveal! 
    end.print_board
  end
  
  def [](x,y)
    @board[x][y]
  end
  
  def surrounding_positions(pos)
    x, y = pos
    
    POSITION_DELTAS.map{|dx, dy| [x + dx, y + dy]}.select do |x, y| 
      x.between?(0, Board::BOARD_SIDE_LENGTH - 1) &&
      y.between?(0, Board::BOARD_SIDE_LENGTH - 1)
    end
  end
  
  def surrounding_tiles(pos)
    surrounding_positions(pos).map { |x, y| self[x, y] }
  end
  
  def uncover(move)
    queue = [move]

    until queue.empty?
      move = queue.shift
      self[*move].reveal!
      
      neighbors = surrounding_positions(move)
      if surrounding_tiles(move).none? { |tile| tile.value == :mine }
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
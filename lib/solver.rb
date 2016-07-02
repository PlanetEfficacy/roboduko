require 'pry'

class Solver

  def initialize(puzzle_text)

      @digits = (1..9).to_a
      @rows = ("A".."I").to_a
      @cols = @digits
      @spaces = @rows.product(@cols).collect { |x,y| x + y.to_s }
      @squares = create_squares
      @grid = parse_grid(puzzle_text)
      @puzzle_solved = false

  end

  def create_squares
    squares = []
    letters = [["A","B","C"],["D","E","F"],["G","H","I"]]
    numbers = [["1","2","3"],["4","5","6"],["7","8","9"]]
    letters.each do |letter_group|
      numbers.each do |number_group|
        squares << letter_group.product(number_group).collect { |x,y| x + y }
      end
    end
    return squares
  end

  def parse_grid(puzzle_text)
    grid = Hash.new
    puzzle_text = check_puzzle_text(puzzle_text)
    @spaces.each_with_index do |space, index|
      puzzle_text_space = puzzle_text[index]
      if puzzle_text_space == " "
        grid[space] = "123456789"
      else
        grid[space] = puzzle_text_space
      end
    end
    return grid
  end

  def check_puzzle_text(puzzle_text)
    puzzle_rows = puzzle_text.split("\n")
    one_dimensional_puzzle = puzzle_rows.map do |row|
      row.ljust(9, " ").chars
    end
    return one_dimensional_puzzle.flatten!
  end

  def solve
    until @puzzle_solved
      @puzzle_solved = puzzle_solved?
      assign_values
    end
    return format_grid
  end

  def puzzle_solved?
    unsolved_squares = @grid.select { |space, values| values.length > 1 }
    return unsolved_squares.empty?
  end

  def assign_values
    @grid.each do |space, value|
      if (value.length > 1)
        eliminate(space, value)
      end
    end
  end

  def eliminate(space, values)
    peers = get_peers(space)
    peers.each do |peer|
      if @grid[peer].length == 1
        values.sub!(@grid[peer], "")
      end
    end
    @grid[space] = values
  end

  def format_grid
    grid_as_string = ""
    @grid.values.each_with_index do |value, index|
      grid_as_string += (index % 9 == 0) && (index > 0) ? "\n" + value : value
    end
    return grid_as_string
  end

  def get_col(space)
    peer_column = @spaces.find_all do |this_space|
      this_space[1] == space[1]
    end
  end

  def get_row(space)
    peer_row = @spaces.find_all do |this_space|
      this_space[0] == space[0]
    end
  end

  def get_square(space)
    peer_square = @squares.find do |square|
      square.include?(space)
    end
  end

  def get_units(space)
    return units = [get_col(space), get_row(space), get_square(space)]
  end

  def get_peers(space)
    peers = get_units(space).flatten.uniq
    peers.delete(space)
    return peers
  end

end

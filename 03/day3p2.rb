require 'debug'
require 'pry'
# FILE = 'test_input.txt'
FILE = 'input.txt'
DEBUG = true

def log(str)
  return unless DEBUG
  puts str
end
def integer?(c)
  !!Integer(c, exception: false)
end

rows = File.read(FILE).split("\n")

IntegerCoordinate = Struct.new(:start, :final, :str_value) do
  def value
    self.str_value.to_i
  end

  def to_s
    "#{start}:#{final}=#{str_value}"
  end

  def activate!
    @active = true
  end

  def activated?
    !!@active
  end
end

SymbolCoordinate = Struct.new(:index, :part)

integer_coordinates = []
symbol_coordinates = []

rows.each do |row|
  row_index = 0

  # handles a row
  row_integer_coordinates = []
  row_symbol_coordinates = []

  while row_index < row.length
    c = row[row_index]

    if integer?(c)
      int_set = c
      j = row_index + 1
      while integer?(row[j])
        int_set << row[j]
        j+=1
      end
      puts "found set '#{int_set}'"
      # push the found coordinates into an array for this row
      row_integer_coordinates.push IntegerCoordinate.new(row_index, j - 1, int_set)
      # update the iterator so we don't rescan from the second digit of this integer set
      row_index += int_set.length
    else
      if c != '.'
        row_symbol_coordinates.push SymbolCoordinate.new(row_index, c)
      end
      row_index+=1
    end
  end

  # this row done, save results and then scan next
  integer_coordinates.push(row_integer_coordinates)
  log "pushing #{row_symbol_coordinates} for row #{row}"
  symbol_coordinates.push(row_symbol_coordinates)
end

gear_coords = []
# look through each col in each row for "gears" (*)
rows.each.with_index do |row, row_index|
  row.chars.each.with_index do |char, col_index|
    next if char != '*'

    log "got a #{char} at #{row_index}, #{col_index}"
    gear_coords.push [row_index, col_index]
  end
end

gear_connections = []

MAX_ROWS = rows.length
# for each gear coordinate look for a number touching it
gear_coords.each do |gear_x, gear_y|
  start_x = gear_x -1
  start_x = 0 if gear_x < 0

  possible_gear_group = []

  # find numbers touching the gears and store them in gear_connections
  integer_coordinates[start_x, 3].flatten.each do| int_coord|
    if (int_coord.start - 1 .. int_coord.final + 1).include? gear_y
      possible_gear_group.push(int_coord)
      puts "Found #{int_coord.str_value} near gear at #{gear_x} #{gear_y}"
    end
  end
  gear_connections.push possible_gear_group if possible_gear_group.length == 2

end

sum = gear_connections.sum(0) {|group| group[0].value*group[1].value}
puts "sum is #{sum}"

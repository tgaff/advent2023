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

row = rows.first

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

SymbolCoordinate = Struct.new(:index)

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
        row_symbol_coordinates.push SymbolCoordinate.new(row_index)
        puts c
      end
      row_index+=1
    end
  end

  # this row done, save results and then scan next
  integer_coordinates.push(row_integer_coordinates)
  log "pushing #{row_symbol_coordinates} for row #{row}"
  symbol_coordinates.push(row_symbol_coordinates)
end

puts "found coords:\n"
integer_coordinates.each { |ic| puts ic }
puts "symbol  coordinates"
symbol_coordinates.each { |sc| puts sc }


def sym_within_one?(integer_coordinate, symbol_coordinates)
  start = integer_coordinate.start - 1
  final = integer_coordinate.final + 1
  symbol_coordinates.each do |sc|
    return true if (start..final).include? sc.index
  end

  false
end

# we should have both coordinate sets now, lets figure out which match up
integer_coordinates.each.with_index do |coord_row, row_index|
  coord_row.each do |integer_coordinate|

    # check this row
    if sym_within_one?(integer_coordinate, symbol_coordinates[row_index])
      integer_coordinate.activate!
      next
    end

    # check next row
    next_row_index = row_index + 1
    if next_row_index < integer_coordinates.length # its a valid row
      if sym_within_one?(integer_coordinate, symbol_coordinates[next_row_index])
        integer_coordinate.activate!
        next
      end
    end
    # check previous row
    prev_row_index = row_index - 1
    if prev_row_index > -1 # its a valid row
      if sym_within_one?(integer_coordinate, symbol_coordinates[prev_row_index])
        integer_coordinate.activate!
        next
      end
    end
  end
end

sum = integer_coordinates.flatten.filter(&:activated?).map(&:value).sum
puts "Sum: #{sum}"
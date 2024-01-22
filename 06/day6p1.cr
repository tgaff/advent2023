require "./command"


module Store
  class_property times
  class_property distances
  @@times = [] of UInt32
  @@distances = [] of UInt32
end

# parse file into store
read_command_line
input = read_input_file
valid_lines = input.split("\n").select {|line| !line.blank? }

raise Exception.new("file is weird") unless valid_lines.size == 2

def parse_file_line(line)
  b = line.split(" ").map(&.strip).select {|o| o.size > 0 }
  b.shift # remove text at beginning
  b.map(&.to_i).map {|i| UInt32.new(i) }
end

valid_lines.each do |vl|
  if vl.includes?("Time:")
    Store.times = parse_file_line(vl)
  elsif (vl.includes?("Distance:"))
    Store.distances = parse_file_line(vl)
  else
    raise Exception.new("something weird about this file line: #{vl}")
  end
end


possible_solutions = quadriticize_for(distance:, d min_time: t)
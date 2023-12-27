require "option_parser"
require "./records"
require "./seed_finder"

module Options
  class_property file_name
  @@file_name = ""
end


parser = OptionParser.parse do |parser|
  parser.banner = "Almanac App"

  parser.on "-f FN", "--file=FN", "file" do |fn|
    puts "file #{fn}"
    Options.file_name = fn
  end
end

parser.parse

def is_digit?(c : String | Char)
  c.to_i

  return true
rescue ArgumentError
  return false
end


# returns array of "from" type and "to" type (e,g soil to fertilizer)
def get_mapping_type_from_str(line : String)
  return ["seeds"] if line.starts_with?("seeds:")

  return line.split(" ")[0].split("-to-")
end

struct Mapping
  property id, associated_id

  def initialize(@id : Int64, @associated_id : Int64)
  end
end

def find_mapping_for_id(find_id : Int64, line)
  line_split = line.split(" ").map { |s| s.strip }
  # puts "working line #{line_split}"
  number_of_times = line_split[2].to_i
  current_model_first_id = line_split[1].to_i64
  to_model_first_id = line_split[0].to_i64

  number_of_times.times do |n|
    id = (current_model_first_id + n)
    next unless id == find_id

    associated_id = to_model_first_id + n

    return Mapping.new(id: id, associated_id: associated_id)
  end
end



# file parsing
file = File.new(Options.file_name)
content = file.gets_to_end
file.close
lines = content.split("\n")

current_chunk = [] of String

alias ArrString = Array(String)

def process_file_lines(lines, work_chunk : ArrString, find_id : Int64)
  current_chunk = [] of String
  lines.each do |line|
    # skip if empty
    next if line.chars.size == 0

    # if current chunk is seeds, skip
    if line.starts_with? "seeds:"
      next
    # set which mapping we're building if starts with char
    elsif !is_digit?(line.chars[0])
      current_chunk = get_mapping_type_from_str(line)
    elsif current_chunk == work_chunk # don't continue past the limit
      # process as a mapping if right work chunk
      # process_group_mapping(type: current_chunk.first, associated_type: current_chunk.last, line: line)
      mapping = find_mapping_for_id(find_id, line)
      return mapping unless mapping.nil?
    end
  end
end


Records.seed_ids = SeedFinder.process_file_for_seeds(lines)

puts "seeds:"
puts Records.seed_ids
puts "-----------------------------------------"

seed_id = Records.seed_ids.first
x = process_file_lines(lines, ["seed", "soil"], seed_id)

def find_location_for_seed_id(seed_id, lines)
  id : Int64 = seed_id
  puts "very well, searching for seed_id #{seed_id}"

  Records::TYPES.each.with_index do |from_type, i|
    to_type = Records::TYPES[i + 1]
    # puts "looking for match at [#{from_type}, #{to_type}] for #{id}"
    this_batches_found_mapping = process_file_lines(lines, [from_type, to_type], id)

    if to_type == Records::TYPES.last
      return this_batches_found_mapping.associated_id unless this_batches_found_mapping.nil?
      return id
    end
    if this_batches_found_mapping.nil?
      puts "no match on [#{from_type}, #{to_type}] from seed_id #{seed_id} currently searching #{id}, will re-use old one"
      next
    end

    id = this_batches_found_mapping.associated_id
  end

end

# puts find_location_for_seed_id(Records.seed_ids.first, lines)
alias SeedLocationMap = StaticArray(Int64, 2)
channel = Channel(SeedLocationMap).new() # process each segment in parallel

Records.seed_ids.each do |seed_id|
  spawn do
    puts "\n\n"
    loc_id = find_location_for_seed_id(seed_id, lines)

    puts "the location for seed #{seed_id} is location #{loc_id}"
    results = Int64.static_array(seed_id || 0, loc_id|| 0)
    channel.send(results)
  end
end

results = [] of SeedLocationMap
Records.seed_ids.size.times do
  res = channel.receive
  results.push res
  puts "received response #{res[0]} => #{res[1]}"
end

puts "___________________________"
puts "sorted by location id"
results.sort {|res_a, res_b| res_a[1] <=> res_b[1] }.each do |res|
  puts "seed #{res[0]} corresponds to location #{res[1]}"
end
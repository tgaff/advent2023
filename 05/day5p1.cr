INPUT_FILE = "test_input.txt"


# class Seed
#   property soil_id : Int32?
# end

# class Soil
#   property fertilizer_id : Int32?
# end

# class Fertilizer
#   property water_id : Int32?
# end

class ModelThing
  getter id : Int32?
  property associated_id : Int32?
  getter type : String
  getter associated_type : String

  def initialize(type, associated_type, id)
    @type = type
    @associated_type = associated_type
    @id = id
  end
end

def is_digit?(c : String | Char)
  c.to_i

  return true
rescue ArgumentError
  return false
end

def get_seeds_from_seeds_line(line : String)
  seeds = [] of Int32
  line.split(":")[1].split(" ").each do |num|
    next unless is_digit?(num)
    seeds.push num.to_i
  end

  seeds
end

# returns array of "from" type and "to" type (e,g soil to fertilizer)
def get_mapping_type_from_str(line : String)
  return ["seeds"] if line.starts_with?("seeds:")

  return line.split(" ")[0].split("-to-")
end


def process_group_mapping(type : String, associated_type : String, line : String)
  line_split = line.split(" ").map { |s| s.strip }
  puts "working line #{line_split}"
  number_of_times = line_split[2].to_i
  current_model_type = type
  current_model_first_id = line_split[1].to_i
  to_type = associated_type
  to_model_first_id = line_split[0].to_i

  number_of_times.times do |n|
    model = ModelThing.new(current_model_type, to_type, current_model_first_id + n)
    model.associated_id = to_model_first_id + n
    puts model
    Records.mappings[current_model_type].save model
  end
end
# file parsing
file = File.new(INPUT_FILE)
content = file.gets_to_end
file.close
lines = content.split("\n")

current_chunk = [] of String

seeds = [] of Int32
module Records
  class_property mappings

  @@mappings = {
    # "seed" => [] of ModelThing,
    # "soil" => [] of ModelThing,
    # "fertilizer" => [] of ModelThing,
    # "water" => [] of ModelThing,
    # "light" => [] of ModelThing,
    # "temperature" => [] of ModelThing,
    # "humidity" => [] of ModelThing,
    # "location" => [] of ModelThing
    "seed" => Store.new,
    "soil" => Store.new,
    "fertilizer" => Store.new,
    "water" => Store.new,
    "light" => Store.new,
    "temperature" => Store.new,
    "humidity" => Store.new,
    "location" => Store.new,
  }

  class Store
    @_internal_hash = {} of Int32 => ModelThing

    def save(record : ModelThing)
      raise Exception.new("missing an id") if record.id.nil?
      @_internal_hash[record.id.as(Int32)] = record
    end

    def inspect
      @_internal_hash.values.map do |k|
        k.inspect
      end.join("\n")
    end
  end
end

lines.each do |line|
  # skip if empty
  next if line.chars.size == 0
  # set which mapping we're building if starts with char
  if !is_digit?(line.chars[0])
    current_chunk = get_mapping_type_from_str(line)
  # if current chunk is seeds, special process this
  elsif current_chunk[0] == "seeds"
    seeds = get_seeds_from_seeds_line(line)
  else
    # process as a mapping if starts with a number
    process_group_mapping(type: current_chunk.first, associated_type: current_chunk.last, line: line)
  end
end
puts "seeds:"
puts seeds

puts "mappings:"
s1 = Records.mappings["seed"]
puts s1.inspect
puts Records.mappings["humidity"].inspect
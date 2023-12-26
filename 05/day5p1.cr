require "option_parser"

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

class ModelThing
  getter id : Int32?
  property associated_id : Int32?
  getter type : String
  getter associated_type : String

  def initialize(type, associated_type, id, associated_id : Int32? = nil)
    @type = type
    @associated_type = associated_type
    @id = id
    @associated_id = associated_id || id
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

    Records.mappings[current_model_type].save model
  end
end

# file parsing
file = File.new(Options.file_name)
content = file.gets_to_end
file.close
lines = content.split("\n")

current_chunk = [] of String

module Records
  class_property mappings
  class_property seed_ids

  TYPES = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  @@seed_ids = [] of Int32

  @@mappings = {
    "seed" => Store.new("seed", "soil"),
    "soil" => Store.new("soil", "fertilizer"),
    "fertilizer" => Store.new("fertilizer", "water"),
    "water" => Store.new("water", "light"),
    "light" => Store.new("light", "temperature"),
    "temperature" => Store.new("temperature", "humidity"),
    "humidity" => Store.new("humidity", "location"),
  }

  class Store
    @_internal_hash = {} of Int32 => ModelThing

    def initialize(from_type : String, to_type : String)
      @from_type = from_type
      @to_type = to_type
    end

    def find_by_id(id : Int32)
      rec = @_internal_hash.fetch(id) do |id|
        puts "failed to find a corresponding record for id #{id} in the #{@from_type} store"
        # generate a replacement

        ModelThing.new(@from_type, @to_type, id)
      end

      rec
    end

    def has_an_association?
      @to_type.present?
    end

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

  # if current chunk is seeds, special process this
  if line.starts_with? "seeds:"
    puts "found some seeds"
    Records.seed_ids = get_seeds_from_seeds_line(line)

  # set which mapping we're building if starts with char
  elsif !is_digit?(line.chars[0])
    current_chunk = get_mapping_type_from_str(line)
  else
    # process as a mapping if starts with a number
    process_group_mapping(type: current_chunk.first, associated_type: current_chunk.last, line: line)
  end
end
puts "seeds:"
puts Records.seed_ids


puts "-----------------------------------------"


def find_location_for_seed_id(seed_id : Int32)
  next_piece = Records.mappings["seed"].find_by_id(seed_id)
  until next_piece.associated_type == "location"
    puts next_piece.inspect
    puts "got nil associated_id on #{next_piece.inspect}!"
    next_piece = Records.mappings[next_piece.associated_type.as(String)].find_by_id(next_piece.associated_id.as(Int32))
  end

  raise Exception.new("#{next_piece.inspect} is not a humidity!") unless next_piece.type == "humidity"
  return next_piece.associated_id
end

Records.seed_ids.each do |seed_id|
  loc_id = find_location_for_seed_id(seed_id)

  puts "the location for seed #{seed_id} is location #{loc_id}"
end
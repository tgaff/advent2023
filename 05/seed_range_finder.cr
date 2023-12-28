class SeedRangeFinder
  def self.process_file_for_seeds(lines)
    arr = [] of Int64
    lines.each do |line|
      next if line.chars.size == 0
      if line.starts_with? "seeds:"
        puts "found some seeds"
        arr = get_seeds_from_seeds_line(line)
      end
    end

    return arr
  end

  alias Batch = Array(String)

  # rewritten for seed ranges
  private def self.get_seeds_from_seeds_line(line : String)
    seeds = [] of Int64
    arr =  line.split(": ")[1].split(" ").map(&.strip)
    raise Exception.new("these seeds smell weird") unless arr.size.even?


    batches = [] of Batch

    (arr.size / 2).to_i.times do |i|
      batches.push [ arr[i*2], arr[i*2 + 1] ]
    end

    batches.each do |batch|
      beginning = batch.first.to_i64
      ultimate_length = batch.last.to_i64
      ultimate_length.times do |i|
        seeds.push(beginning + i)
      end
      puts seeds.size
    end

    seeds
  end
end

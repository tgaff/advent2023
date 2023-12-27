class SeedFinder
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

  private def self.get_seeds_from_seeds_line(line : String)
    seeds = [] of Int64
    line.split(":")[1].split(" ").each do |num|
      next unless is_digit?(num)
      seeds.push num.to_i
    end

    seeds
  end
end

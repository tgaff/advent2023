require "option_parser"

module Options
  class_property file_name
  @@file_name = ""
end

parser = OptionParser.parse do |parser|
  parser.banner = "find largest number"
  parser.on "-h", "--help" do
    puts "specify a file with -f FILE_NAME"
    exit
  end
  parser.on "-f FN", "--file=FN", "file" do |fn|
    puts "file #{fn}"
    Options.file_name = fn
  end
end

def is_digit?(c : String | Char)
  c.to_i

  return true
rescue ArgumentError
  return false
end

parser.parse

file = File.new(Options.file_name)
content = file.gets_to_end
file.close
lines = content.split("\n")

largest_so_far = 0

lines.each do |line|
  next if line.chars.size < 2
  next unless is_digit?(line.chars[0])
  line.split(" ").each do |potential_num|
    num = potential_num.to_i64
    largest_so_far = num if num > largest_so_far
  end
end

puts largest_so_far
begin
  largest_so_far.to_i32
rescue OverflowError
  puts "the number exceeds 32bits"
end
require "option_parser"

module Options
  class_property file_name
  @@file_name = ""
end

def read_command_line
  parser = OptionParser.parse do |parser|
    parser.banner = "Usage: "

    parser.on "-f FN", "--file=FN", "file" do |fn|
      Options.file_name = fn
    end

    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
  end

  parser.parse
  if Options.file_name.blank?
    puts parser
    exit 1
  end
end

def read_input_file(file_name = Options.file_name)
  file = File.new(file_name)
  content = file.gets_to_end
  file.close
  content
end

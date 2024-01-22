require "option_parser"

module Options
  class_property file_name
  @@file_name = ""
end

def read_command_line
  parser = OptionParser.parse do |parser|
    parser.banner = "Almanac App"

    parser.on "-f FN", "--file=FN", "file" do |fn|
      Options.file_name = fn
    end
  end

  parser.parse
end

def read_input_file(file_name = Options.file_name)
  file = File.new(file_name)
  content = file.gets_to_end
  file.close
  content
end

require "option_parser"

module Options
  class_property file_name
  @@file_name = ""

  class_property jokers
  @@jokers : Bool = false

end

def read_command_line
  parser = OptionParser.parse do |parser|
    # parser.banner = "App"

    parser.on "-f FN", "--file=FN", "file" do |fn|
      Options.file_name = fn
    end

    parser.on("-j", "--jokers", "Enable Jokers") { Options.jokers = true }
  end

  parser.parse
end

def read_input_file(file_name = Options.file_name)
  file = File.new(file_name)
  content = file.gets_to_end
  file.close
  content
end

require "./util"
require "./node"
require "./solver"



read_command_line

inputs = read_input_file.split("\n")
res = Solver.new(inputs).run

puts "#{res} steps"
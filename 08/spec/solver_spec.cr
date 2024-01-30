require "spec"
require "../solver"
require "../util"

describe Solver do
  input = <<-STRING
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  STRING

  it "finds the correct number of steps" do
    solver = Solver.new(input.split('\n'))
    solver.run.should eq 6
  end

  it "works with the big input too" do
    inputs = read_input_file("./input.txt").split("\n")
    res = Solver.new(inputs).run
    res.should eq 18023
  end
end
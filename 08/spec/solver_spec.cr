require "spec"
require "../solver"

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
end
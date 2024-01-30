require "spec"
require "../node"

describe Node do
  describe "initialization" do
    test_str = "AAA = (BBB, CCC)"

    it "correctly sets the name" do
      node = Node.new(test_str)
      node.name.should eq "AAA"
    end

    it "correctly sets the left side" do
      node = Node.new(test_str)
      node.left.should eq "BBB"
    end

    it "correctly sets the right side" do
      node = Node.new(test_str)
      node.right.should eq "CCC"
    end

  end
end
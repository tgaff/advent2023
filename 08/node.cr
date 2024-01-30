class Node
  property :name
  @left : String
  @right : String
  property :left
  property :right

  def initialize(str : String)
    # "AAA = (BBB, BBB)"
    @name = str.split('=').first.strip
    l_r_arr = str.split('=').last.split(',').map { |k| k.strip }
    @left = l_r_arr.first.strip('(')
    @right = l_r_arr.last.strip(')')
  end
end
require "./util"
require "./hand"

read_command_line
inputs = read_input_file.split("\n")

hands = inputs.map do |input|
  Hand.new(input)
end

hands.sort.reverse

hands_ranked = hands.sort
hands_ranked.reverse_each { |h| puts h.to_s }

sum = hands_ranked.each.with_index.sum(0) do |hand, index|
  hand.bet * (index + 1)
end
puts sum
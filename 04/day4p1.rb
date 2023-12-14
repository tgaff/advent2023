require 'debug'
require 'pry'
# FILE = 'test_input.txt'
FILE = 'input.txt'

def log(str)
  return unless DEBUG
  puts str
end
def integer?(c)
  !!Integer(c, exception: false)
end

file_rows = File.read(FILE).split("\n")

cards = []
file_rows.each do |row|
  x, my_s = row.split('|')
  id_s, win_s = x.split(':')
  cards.push({
    winners: Set.new(win_s.split(' ').map(&:to_i)),
    mine: Set.new(my_s.split(' ').map(&:to_i)),
    id: id_s
  })
end

cards.each do |card|
  intersection = card[:mine].intersection(card[:winners])

  card_value = 2**(intersection.length - 1)
  card_value = 0 if card_value < 1
  puts "#{card[:id]} value #{card_value}"
  card[:value] = card_value
end

total_value = cards.sum(0) {|card| card[:value] }

puts "total #{total_value}"
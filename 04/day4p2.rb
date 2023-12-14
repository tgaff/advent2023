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
    id: id_s.split(' ').last.to_i
  })
end

card_copy_counts = Array.new(cards.length, 1)
cards.each.with_index do |card, card_index|
  intersection = card[:mine].intersection(card[:winners])

  card_value = 2**(intersection.length - 1)
  card_value = 0 if card_value < 1
  puts "#{card[:id]} value #{card_value}"
  card[:value] = card_value
  card[:intersection_count] = intersection.length

  # we repeat adding new lower cards for each copy of the current card
  copies_of_this_card = card_copy_counts[card_index]
  copies_of_this_card.times do |copy|
    # as deep as the number of 'wins'
    intersection.length.times do |i|
      j = card_index + 1 + i
      card_copy_counts[j] += 1 unless card_copy_counts[j].nil?
    end
  end
end

puts card_copy_counts.sum(0)
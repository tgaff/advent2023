require 'debug'

FILE = 'input.txt'
DEBUG = true

def log(str)
  return unless DEBUG
  puts str
end

module IntStrToys
  def integer_from_s(str)
    Integer(
      str.chars.filter { |c| Integer(c, exception: false) }.join
    )
  end
end

Handful = Struct.new(:red, :green, :blue) do
  include IntStrToys

  def from_s(s)
    # default values
    self.red = 0; self.green = 0; self.blue = 0

    s.split(',').map do |color_and_number|
      color_and_number.strip!
      if color_and_number.end_with?('green')
        self.green = integer_from_s(color_and_number)
      elsif color_and_number.end_with?('red')
        self.red = integer_from_s(color_and_number)
      elsif color_and_number.end_with?('blue')
        self.blue = integer_from_s(color_and_number)
      else
        fail StandardError.new, "Couldn't parse '#{color_and_number}'"
      end
    end
  end
end

class Game
  include IntStrToys
  attr_reader :id, :handfuls

  def initialize(input_line)
    identifier, sets = input_line.split(':')

    @id = integer_from_s(identifier)
    @handfuls = []

    sets.split(';').map do |grab|
      handful = Handful.new
      handful.from_s(grab)
      puts handful

      @handfuls.push handful
    end
  end

  def rgb_combo_possible?(r,g,b)
    return false unless color_possible?(:red, r)
    return false unless color_possible?(:green, g)
    return false unless color_possible?(:blue, b)

    true
  end

  private

  def color_possible?(color, value)
    return false if @handfuls.any? { |hand| hand.send(color) > value }

    true
  end

end

inputs = File.read(FILE).split("\n")

games = inputs.map do |line|
  Game.new(line)
end

bag = [12, 13, 14]
ids_that_match_bag = games.filter { |g| g.rgb_combo_possible?(*bag) }.map(&:id)

puts ids_that_match_bag

puts "Sum of IDs that match = #{ids_that_match_bag.sum}"
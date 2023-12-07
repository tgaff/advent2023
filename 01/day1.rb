FILE = 'input.txt'
DEBUG = true


NUMERICAL_SUBSTITUTIONS = (1..9).map { |k| [k.to_s, k] }.to_h.merge({
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9,
}).sort_by(&:length).freeze

def find_first_digit(input)
  input.chars.find do |c|
    Integer(c, exception: false)
  end
end

def find_last_digit(input)
  find_first_digit(input.reverse)
end

def process_words_to_actual_digits(line)
  found = []
  log "Starting on '#{line}'"

  line.length.times do |t|
    NUMERICAL_SUBSTITUTIONS.each do |sub_key, sub_val|
      if line[t, t+5].start_with?(sub_key)
        found.push sub_val
      end
    end
  end

  found.to_s
end

def log(str)
  return unless DEBUG
  puts str
end

inputs = File.read(FILE).split("\n")

xinputs = <<~SAMPLE.split("\n")
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
SAMPLE


out = inputs.reduce(0) do |sum, input|
  input = process_words_to_actual_digits(input)

  row_sum = (find_first_digit(input) + find_last_digit(input) ).to_i

  log "Row val: #{row_sum}\n\n"
  row_sum + sum
end

puts  "total: #{out}"
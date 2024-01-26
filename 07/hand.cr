class Hand
  @cards : Array(Char)
  getter :cards
  @bet : UInt32
  getter :bet

  @hand_type : Symbol
  getter :hand_type

  HAND_TYPE_ORDER = [
    :five_of_a_kind,
    :four_of_a_kind,
    :full_house,
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card
  ]

  def initialize(input_str : String)
    hand_str, bet_str = input_str.split(" ")
    @cards = hand_str.upcase.chars
    @bet = bet_str.to_u32
    @hand_type = check_hand_type
  end

  def <=>(other)
    if @hand_type == other.hand_type
      # in this case we have to compare card by card
      ret_val = 0
      5.times do |i|
        ret_val = card_val(cards[i]).<=> card_val(other.cards[i])
        return ret_val unless ret_val == 0
      end
      # if they were equal all the way through
      return 0
    else
      return hand_type_higher_than?(other.hand_type) ? 1 : -1
    end

    return
  end

  def card_val(char)
    return case char
    when 'A'
      14
    when 'K'
      13
    when 'Q'
      12
    when 'J'
      11
    when 'T'
      10
    else
      char.to_i
    end
  end

  def self.hand_type_rank(hand_type)
    7 - (HAND_TYPE_ORDER.index { |ht| ht == hand_type } || -1)
  end

  private def hand_type_higher_than?(other_hand_type)
    self.class.hand_type_rank(@hand_type) > self.class.hand_type_rank(other_hand_type)
  end



  private def check_hand_type
    h = Hash(Char, Int64).new(0)

    @cards.each { |cv| h[cv] = h[cv]+1 }

    same_card_counts = h.values.sort.reverse
    if same_card_counts.first == 5
      return :five_of_a_kind
    elsif same_card_counts.first == 4
      return :four_of_a_kind
    elsif same_card_counts.first == 3 && same_card_counts[1] == 2
      return :full_house
    elsif same_card_counts.first == 3
      return :three_of_a_kind
    elsif same_card_counts.first == 2
      return :two_pair if same_card_counts[1] == 2
      return :one_pair
    else
      return :high_card
    end
  end

  def to_s
    "Hand #{@cards.join} #{hand_type}"
  end
end
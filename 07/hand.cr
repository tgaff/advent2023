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
      Options.jokers ? 0 : 11
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
    j_count = 0

    h = Hash(Char, Int64).new(0)
    if Options.jokers
      @cards.each do |cv|
        if cv == 'J'
          j_count += 1
        else
          h[cv] = h[cv]+1
        end
      end
    else
      @cards.each { |cv| h[cv] = h[cv]+1 }
    end

    same_card_counts = h.values.sort.reverse
    s1 = same_card_counts.fetch(0, 1)
    s2 = same_card_counts.fetch(1, 1)
    puts "hand jokers #{j_count} #{@cards.join("")} '#{s1}' '#{s2}'"

    res = if j_count == 0
      if s1 == 5
        :five_of_a_kind
      elsif s1 == 4
        :four_of_a_kind
      elsif s1 == 3 && s2 == 2
        :full_house
      elsif s1 == 3
        :three_of_a_kind
      elsif s1 == 2
        if s2 == 2
          :two_pair
        else
          :one_pair
        end
      else
        :high_card
      end
    elsif j_count >= 4
      :five_of_a_kind
    elsif j_count == 3
      if s1 == 2
        :five_of_a_kind
      else
        :four_of_a_kind
      end
    elsif j_count == 2
      if s1 == 3
        :five_of_a_kind
      elsif s1 == 2
        :four_of_a_kind
      else
        :three_of_a_kind
      end
    elsif j_count == 1
      if s1 == 4
        :five_of_a_kind
      elsif s1 == 3
        :four_of_a_kind
      elsif s1 == 2 && s2 == 2
        :full_house
      elsif s1 == 2
        :three_of_a_kind
      else
        :one_pair
      end
    else
      raise "OOPS"
    end

    res
  end

  def to_s
    "Hand #{@cards.join} #{hand_type}"
  end
end
class Participant
  attr_accessor :hand

  def initialize(deck)
    @hand = []
    @deck = deck
  end

  def display_hand
    puts "[#{hand.map(&:to_s).join(', ')}]"
    puts "Total: #{total}"
  end

  def total
    score = @hand.reduce(0) { |total, card| total + card.points }
    if score > 21
      hand.map(&:value).count('Ace').times do
        score -= 10
        break if score <= 21
      end
    end
    score
  end

  def busted?
    total > 21
  end
end

class Player < Participant
  def hit
    puts "You hit!"
    hand << @deck.deal
    display_hand
  end

  def stay
    puts "You stay!"
  end
end

class Dealer < Participant
  def hit
    puts "Dealer hits!"
    hand << @deck.deal
    display_hand
  end

  def stay
    puts "Dealer stays!"
  end
end

class Deck
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace']
  SUITES = ['Spades', 'Hearts', 'Clubs', 'Diamonds']

  def initialize
    @stack = []
    VALUES.each do |value|
      SUITES.each do |suite|
        @stack << Card.new(suite, value)
      end
    end
    @stack.shuffle!
  end

  def deal
    @stack.pop
  end
end

class Card
  attr_reader :value

  def initialize(suite, value)
    @suite = suite
    @value = value
  end

  def points
    case @value
    when 2..10 then @value
    when 'Ace' then 11
    else 10
    end
  end

  def to_s
    "#{@value} of #{@suite}"
  end
end

class Game
  def initialize
    @deck = Deck.new
    @player = Player.new(@deck)
    @dealer = Dealer.new(@deck)
  end

  def start
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end

  def deal_cards
    2.times do
      @player.hand << @deck.deal
      @dealer.hand << @deck.deal
    end
  end

  def show_initial_cards
    print "Player has: "
    @player.display_hand
    print "Dealer has: "
    @dealer.display_hand
  end

  def player_turn
    loop do
      puts "Hit or stay?"
      answer = gets.chomp[0].downcase
      break if answer == 's'
      @player.hit
      if @player.busted?
        puts "Uh oh! You busted. Dealer wins!"
        exit
      end
    end
  end

  def dealer_turn
    @dealer.hit until @dealer.total >= 17
    if @dealer.busted?
      puts "Dealer busted. You win!"
      exit
    end
    @dealer.stay
  end

  def show_result
    puts "Player has a total of #{@player.total}. Dealer has a total of #{
      @dealer.total}."
    if @player.total > @dealer.total
      puts "Player wins!"
    elsif @dealer.total > @player.total
      puts "Dealer wins!"
    else
      puts "It's a tie!"
    end
  end
end

Game.new.start
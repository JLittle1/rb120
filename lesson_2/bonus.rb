class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def >(other_move)
    return other_move.scissors? if rock?
    return other_move.rock? if paper?
    return other_move.paper? if scissors?
  end

  def <(other_move)
    return other_move.paper? if rock?
    return other_move.scissors? if paper?
    return other_move.rock? if scissors?
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name
  attr_reader :history

  def initialize
    @history = []
    set_name
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
    @history << self.move
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
    @history << self.move
  end
end

class R2D2 < Computer
  def choose
    'rock'
  end
end

class Hal < Computer
  def choose
    ['scissors', 'scissors', 'scissors', 'scissors', 'rock'].sample
  end
end

class Chappie < Computer
  def choose
    if history.empty?
      Move::VALUES.sample
    else
      case history[-1]
      when 'rock' then 'paper'
      when 'paper' then 'scissors'
      when 'scissors' then 'rock'
      end
    end
  end
end

class Sonny < Computer
  def choose
    if history.empty?
      Move::VALUES.sample
    else
      case history[-1]
      when 'rock' then 'scissors'
      when 'paper' then 'rock'
      when 'scissors' then 'paper'
      end
    end
  end
end

class Number5 < Computer
  def choose
    Move::VALUES.sample
  end
end


class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end
    answer.downcase == 'y'
  end

  def display_history
    move_sets = human.history.zip(computer.history)
    puts "Round    Player vs Computer"
    move_sets.each_with_index do |set, idx|
      puts "Round #{idx + 1}: #{set[0]} vs #{set[1]}"
    end
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      break unless play_again?
    end
    display_history
    display_goodbye_message
  end
end

RPSGame.new.play

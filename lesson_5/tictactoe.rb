require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def find_winning_move(marker)
    WINNING_LINES.each do |line|
      if @squares.values_at(*line).map(&:marker).count(marker) == 2
        return unmarked_keys.intersection(line).first
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  DEFAULT_NAMES = ['Conan', 'Akiro', 'Subotai', 'Thorgrim', 'Thulsa Doom']

  attr_accessor :name, :marker, :score

  def initialize
    @name = DEFAULT_NAMES.sample
    @score = 0
  end
end

class TTTGame
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
  end

  def play
    clear
    display_welcome_message
    loop do
      set_up_game
      main_game
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  def set_up_game
    reset
    @human = Player.new
    @computer = Player.new
    ask_for_name
    set_human_marker
    set_computer_marker
    determine_first_to_move
    @current_marker = @first_to_move
  end

  def ask_for_name
    puts "What is your name?"
    @human.name = gets.chomp
  end

  def set_human_marker
    puts "What would you like your marker to be?"
    @human_marker = gets.chomp
    human.marker = @human_marker
  end

  def set_computer_marker
    @computer_marker = @human_marker == 'O' ? 'X' : 'O'
    computer.marker = @computer_marker
  end

  def determine_first_to_move
    puts 'Who should play first? p for player, c for computer, r for random'
    loop do
      response = gets.chomp.downcase[0]
      @first_to_move = case response
      when 'p' then @human_marker
      when 'c' then @computer_marker
      when 'r' then [@human_marker, @computer_marker].sample
      end
      break if @first_to_move
      puts 'Invalid input. Please enter p, c, or r'
    end
  end

  def main_game
    loop do
      display_board
      player_move
      display_result
      if human.score == 5 || computer.score == 5
        display_victor
        break
      end
      puts "Press enter to continue:"
      gets.chomp
      reset
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_victor
    if human.score == 5
      puts "With five victories, #{human.name} wins the round!"
    elsif computer.score == 5
      puts "With five victories, computer wins the round!"
    end
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == @human_marker
  end

  def display_board
    puts "#{human.name} is a #{human.marker}. #{computer.name} is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def joinor(arr, seperator=', ', word='or')
    return arr[0].to_s if arr.size == 1
    return "#{arr[0]} #{word} #{arr[1]}" if arr.size == 2
    arr[0...-1].join(seperator) + seperator + word + ' ' + arr[-1].to_s
  end

  def computer_moves
    square = board.find_winning_move(@computer_marker)
    square ||= board.find_winning_move(@human_marker)
    square ||= 5 if board.unmarked_keys.include?(5)
    square ||= board.unmarked_keys.sample
    board[square] = @computer_marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = @computer_marker
    else
      computer_moves
      @current_marker = @human_marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      human.score += 1
      puts "You won!"
    when computer.marker
      computer.score += 1
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
    puts "Score: #{human.name} #{human.score} - #{computer.name} #{computer.score}"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @current_marker = @first_to_move
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play

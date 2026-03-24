require_relative 'display'

class Game
  include Display
  attr_reader :code, :board_state
  COLORS = {
    'r' => RED,
    'g' => GREEN,
    'b' => BLUE,
    'y' => YELLOW
  }

  def initialize
    @code = 4.times.map { [RED, GREEN, BLUE, YELLOW].sample }
    @board_state = Array.new(12) {{ guess: nil, pins: nil }}
  end

  def player_turn
    12.times do |i|
      clear_screen
      render_turn(@board_state)
      guess = get_guess(i)
      evaluate_guess(guess, i)
      if @board_state[i][:pins] == [4, 0]
        clear_and_announce('You broke the code!')
        render_turn(@board_state)
        puts 'GAME OVER'
        break
      end
      if i == 11
        clear_and_announce('Out of guesses!')
        render_turn(@board_state)
        puts 'GAME OVER'
      end
    end
  end

  private

  def get_guess(turn)
    guess = []
    puts 'Guess the code:'
    4.times do |i|
      until COLORS.value?(guess[i])
        print "#{i + 1}. "
        guess[i] = COLORS[gets.chomp]
      end
    end
    @board_state[turn][:guess] = guess
    guess
  end

  def evaluate_guess(guess, turn)
    exact = guess.zip(@code).count { |g, c| g == c }
    color = guess.tally.sum { |color, count| [count, @code.tally[color] || 0].min }
    color -= exact
    @board_state[turn][:pins] = [exact, color]
  end
end

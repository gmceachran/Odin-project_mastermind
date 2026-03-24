require_relative 'display'
require_relative 'computer_solver'

class Game
  include Display
  attr_reader :code, :board_state, :role

  COLORS = {
    'r' => RED,
    'g' => GREEN,
    'b' => BLUE,
    'y' => YELLOW
  }.freeze

  def self.feedback_for(guess, secret)
    exact = guess.zip(secret).count { |g, c| g == c }
    overlap = guess.tally.sum { |peg, count| [count, secret.tally[peg] || 0].min }
    [exact, overlap - exact]
  end

  def initialize(role:)
    @role = role
    @board_state = Array.new(12) { { guess: nil, pins: nil } }
    @code = random_code if @role == :human_guesser
  end

  def play
    case @role
    when :human_guesser then play_human_guesser
    when :human_codemaker then play_human_codemaker
    else raise ArgumentError, "unknown role: #{@role.inspect}"
    end
  end

  private

  def random_code
    4.times.map { PEG_VALUES.sample }
  end

  def play_human_guesser
    12.times do |i|
      clear_screen
      render_turn(@board_state)
      guess = read_guess_for_turn(i)
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
        puts "The code was: #{@code.join(' ')}"
        puts 'GAME OVER'
      end
    end
  end

  def play_human_codemaker
    clear_screen
    puts 'Enter a secret code. It will be hidden after you finish.'
    @code = read_code_from_human
    clear_screen
    puts 'Secret saved. The computer is guessing.'
    solver = ComputerSolver.new(PEG_VALUES)

    12.times do |i|
      guess = if i.zero?
                ComputerSolver.opening_guess(PEG_VALUES)
              else
                solver.next_guess
              end

      if guess.nil? || solver.empty?
        clear_and_announce('Internal error: no valid codes left.')
        break
      end

      @board_state[i][:guess] = guess
      pins = self.class.feedback_for(guess, @code)
      @board_state[i][:pins] = pins
      solver.prune!(guess, pins)

      if solver.empty?
        clear_and_announce('Inconsistent scoring — check the rules and try again.')
        break
      end

      clear_screen
      render_turn(@board_state)

      if pins == [4, 0]
        puts 'The computer cracked your code!'
        puts 'GAME OVER'
        break
      end

      if i == 11
        puts 'The computer ran out of guesses.'
        puts "Your code was: #{@code.join(' ')}"
        puts 'GAME OVER'
      else
        puts 'Press Enter for the next guess...'
        gets
      end
    end
  end

  def read_code_from_human
    guess = []
    4.times do |idx|
      until COLORS.value?(guess[idx])
        print "#{idx + 1}. "
        guess[idx] = COLORS[gets&.chomp]
      end
    end
    guess
  end

  def read_guess_for_turn(turn)
    puts 'Guess the code:'
    guess = read_code_from_human
    @board_state[turn][:guess] = guess
    guess
  end

  def evaluate_guess(guess, turn)
    @board_state[turn][:pins] = self.class.feedback_for(guess, @code)
  end
end

module Display
  RED = "\e[31m●\e[0m"
  GREEN = "\e[32m●\e[0m"
  YELLOW = "\e[33m●\e[0m"
  BLUE = "\e[34m●\e[0m"
  PEG_VALUES = [RED, GREEN, BLUE, YELLOW].freeze
  EMPTY_SLOT = "\e[90m○\e[0m"
  BLACK_PEG = "\e[90m◆\e[0m"
  WHITE_PEG = "\e[97m◆\e[0m"

  def clear_screen
    system('clear')
  end

  def clear_and_announce(message)
    clear_screen
    puts message
  end

  def prompt_game_role
    clear_screen
    puts 'Mastermind — choose your role:'
    puts '  1 — You guess (the computer sets the secret code)'
    puts '  2 — You set the secret code (the computer guesses)'
    puts 'Colors: r red · g green · b blue · y yellow'
    loop do
      print 'Enter 1 or 2: '
      case gets&.chomp
      when '1' then return :human_guesser
      when '2' then return :human_codemaker
      else puts 'Please enter 1 or 2.'
      end
    end
  end

  def render_guesses(board_state)
    board_state.map do |hash|
      hash[:guess] ? hash[:guess].join(' ') : Array.new(4, EMPTY_SLOT).join(' ')
    end
  end

  def render_pins(board_state)
    board_state.map do |hash|
      pin_counts = hash[:pins]
      if pin_counts.nil?
        '       '
      else
        pins = []
        pin_counts.each_with_index do |count, idx|
          peg = idx.zero? ? BLACK_PEG : WHITE_PEG
          count.times { pins << peg }
        end

        if pins.length < 4
          (4 - pins.length).times { pins << ' ' }
        end

        pins.join(' ')
      end
    end
  end

  def render_board(all_guesses, all_pins)
    puts '╔══════════════════════════╗'
    puts '║    M A S T E R M I N D   ║'
    puts '╠════════════════╦═════════╣'
    all_guesses.each_index do |i|
      puts format('║ %2d.  %s   ║ %s ║', i + 1, all_guesses[i], all_pins[i])
    end
    puts '╚════════════════╩═════════╝'
  end

  def render_turn(board_state)
    all_guesses = render_guesses(board_state)
    all_pins = render_pins(board_state)
    render_board(all_guesses, all_pins)
  end
end

require_relative 'lib/display'
require_relative 'lib/game'

include Display

def run_game
  Game.new(role: prompt_game_role).play
end

run_game

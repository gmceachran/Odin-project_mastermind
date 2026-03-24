require_relative 'lib/game'

def run_game
  game = Game.new
  game.player_turn
end

run_game

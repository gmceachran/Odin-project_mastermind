class ComputerSolver
  def initialize(pegs)
    @possible = pegs.repeated_permutation(4).to_a
  end

  def prune!(guess, feedback)
    @possible.select! { |candidate| Game.feedback_for(guess, candidate) == feedback }
  end

  def next_guess
    @possible.sample
  end

  def empty?
    @possible.empty?
  end

  def self.opening_guess(pegs)
    [pegs[0], pegs[0], pegs[1], pegs[1]]
  end
end

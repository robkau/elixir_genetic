defmodule Portfolio do
  @behaviour Problem
  alias Types.Chromosome

  @target_fitness 185

  @impl true
  def genotype do
    genes = for _ <- 1..10, do: {Genetic.Rng.int_range(10), Genetic.Rng.int_range(10)}
    # genes are a tuple of {roi, risk}
    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    # most roi with lowest risk
    chromosome.genes
    |> Enum.map(fn {roi, risk} -> 2 * roi - risk end)
    |> Enum.sum()
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness > @target_fitness
  end
end

soln = Genetic.run(Portfolio, population_size: 50)

IO.write("\n")
IO.inspect(soln)

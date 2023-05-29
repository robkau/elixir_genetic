defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  # Length of the bit array to maximize
  @size 500

  @impl true
  def genotype do
    genes = for _ <- 1..@size, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: @size}
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?([best | _], generation, temperature), do: best.fitness == @size
end

soln = Genetic.run(OneMax)

IO.write("\n")
IO.inspect(soln)
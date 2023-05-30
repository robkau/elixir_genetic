defmodule Interactive do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = for _ <- 1..10 do <<:rand.uniform(255)::utf8>> end
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_function(chromosome) do
    IO.write("\n")
    IO.inspect(chromosome.genes)
    fit = IO.gets("Does this look cool? From 1 to 10??? ")

    fit
    |> String.trim()
    |> String.to_integer()
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness > 8
  end
end

soln = Genetic.run(Interactive, population_size: 2)

IO.write("\nThe winner is: ")
IO.inspect(soln)

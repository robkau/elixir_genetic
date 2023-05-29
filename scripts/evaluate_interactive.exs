defmodule Interactive do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = [{:rand.uniform(10), :rand.uniform(10)}]
    %Chromosome{genes: genes, size: 1}
  end


  @impl true
  def fitness_function(chromosome) do
    IO.inspect(chromosome)
    fit = IO.gets("Does this look cool? From 1 to 10??? ")
    fit
    |> String.trim()
    |> String.to_integer()
  end

  @impl true
  def terminate?([best |_], generation, temperature) do
      best.fitness > 8
  end
end

soln = Genetic.run(Interactive, population_size: 2)

IO.write("\nThe winner is: ")
IO.inspect(soln)

defmodule Schedule do
  @behaviour Problem
  alias Types.Chromosome

  # Solve problem of how to pick the classes for next semester of school.
  # Each class has difficulty, usefulness, and interest rating
  defp credit_hours, do: [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  defp difficulties, do: [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  defp usefulness, do: [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  defp interest, do: [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  @impl true
  def genotype do
    # genes are binary - each slot is 1 or 0 for taking the class or not.
    genes = for _ <- 1..10, do: Enum.random(0..1)
    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    # multi dimensional goal considering the difficulty, usefulness, and interest of each class
    schedule = chromosome.genes
    fitness = [schedule, difficulties(), usefulness(), interest()]
      |> Enum.zip()
      |> Enum.map(
          fn {class, diff, usef, int} ->
            class * (0.3*usef+0.3*int-0.3*diff)
          end
         )
       |> Enum.sum()

    # solution is a failure if above maximum class limit
    credits =
      schedule
        |> Enum.zip(credit_hours())
        |> Enum.map(fn {class, credits} -> class * credits end)
        |> Enum.sum()

    if credits > 18.0, do: -99999, else: fitness
  end

  @impl true
  def terminate?(_population, generation, temperature) do
    generation >= 1000
  end
end

soln = Genetic.run(
  Schedule,
  crossover_type: &Toolbox.Crossover.single_point/2,
  reinsertion_strategy: &Toolbox.Reinsertion.elitist(&1, &2, &3, 0.1),
  selection_rate: 0.8,
  mutation_rate: 0.1)

IO.inspect(soln)

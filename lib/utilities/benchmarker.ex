defmodule Utilities.Benchmarker do

  def run problem do
    dummy_population = Genetic.initialize(&problem.genotype/0, population_size: 100)

    {dummy_selected_population, _} = Genetic.select(dummy_population, selection_rate: 1.0)

    Benchee.run(
      %{
        "initialize" => fn -> Genetic.initialize(&problem.genotype/0) end,
        "evaluate" => fn -> Genetic.evaluate(dummy_population, &problem.fitness_function/1) end,
        "select" => fn -> Genetic.select(dummy_population, selection_type: &Toolbox.Selection.tournament_no_duplicates(&1, &2, 3)) end,
        "crossover" => fn -> Genetic.crossover(dummy_selected_population) end,
        "mutation" => fn -> Genetic.mutation(dummy_population) end,
        "evolve" => fn -> Genetic.evolve(dummy_population, problem, 0, 0, 0) end
      },
      memory_time: 2
    )
  end
end






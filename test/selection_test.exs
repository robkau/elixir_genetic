defmodule SelectionTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Types.Chromosome

  # todo list of functions to run identical tests for
  def genotype do
    genes = for _ <- 1..10, do: Enum.random(0..1)
    Chromosome.new(genes)
  end

  property "tournament_no_duplicates/2 maintains the size of population" do
    check all(
            start_size <- integer(1..100),
            new_size <- integer(1..100),
            tourn_size <- integer(1..100)
          ) do
      population = Genetic.initialize(&genotype/0, population_size: start_size)

      new_population =
        Toolbox.Selection.tournament_no_duplicates(population, new_size, tourn_size)

      assert length(population) == start_size
      assert length(new_population) == new_size
    end
  end
end

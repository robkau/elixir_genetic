defmodule Toolbox.Selection do
  # Take the most-fit solutions only
  # High fitness, Low genetic diversity, may converge early
  def elite(population, n) do
    population
    |> Enum.take(n)
  end

  # Take random solutions
  # Ignores fitness, Maximizes genetic diversity
  def random(population, n) do
    population
    |> Enum.take_random(n)
  end

  # Pair solutions in a sequence of N tournaments of size tournsize
  # Each tournament consists of random participants
  # Each tournament, select the most fit participant
  # Balances fitness and genetic diversity
  def tournament(population, n, tournsize) do
    0..(n - 1)
    |> Enum.map(fn _ ->
      population
      |> Enum.take_random(tournsize)
      |> Enum.max_by(& &1.fitness)
    end)
  end

  def tournament_no_duplicates(population, n, tournsize) do
    selected = MapSet.new()
    tournament_helper(population, n, tournsize, selected)
  end

  def tournament_helper(population, n, tournsize, selected) do
    if MapSet.size(selected) == n do
      MapSet.to_list(selected)
    else
      chosen =
        population
        |> Enum.take_random(tournsize)
        |> Enum.max_by(& &1.fitness)

      tournament_helper(population, n, tournsize, MapSet.put(selected, chosen))
    end
  end

  # Randomly selects parents with probability of selection equal to fitness
  # Prioritizes fitness while maintaining genetic diversity
  # Duplicate selection possible
  # Todo: extremely slow.
  def roulette(population, n) do
    sum_fitness =
      population
      |> Enum.map(& &1.fitness)
      |> Enum.sum()

    0..(n - 1)
    |> Enum.map(fn _ ->
      u = Genetic.Rng.float() * sum_fitness

      population
      |> Enum.reduce_while(
        0,
        fn x, sum ->
          if x.fitness + sum > u do
            {:halt, x}
          else
            {:cont, x.fitness + sum}
          end
        end
      )
    end)
  end
end

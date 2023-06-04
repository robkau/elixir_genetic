defmodule Toolbox.Reinsertion do
  alias Types.Chromosome

  # Defines reinsertion strategies (how to create new population from parents+children+mutants after a round of evolution)

  # todo p 136 - strategies to grow/shrink/cyclical population

  # Pure reinsertion: keep all children as the entire new population
  def pure(_parents, offspring, _leftovers), do: offspring

  # Elite reinsertion: retain some of the most fit parents for the next population
  # Todo will this grow the population?
  def elitist(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
   n = floor(length(old) * survival_rate)
    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)
    offspring ++ survivors
  end


  # Uniform reinsertion: retain a random selection of parents for next generation
  # Todo will this grow the population?
  def uniform(parents, offspring, leftovers, survival_rate) do
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)
    survivors =
      old
      |> Enum.take_random(n)

    offspring ++ survivors
  end
end

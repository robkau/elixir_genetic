defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  @target_word "supercalifragilisticexpialidocious"

  @impl true
  def genotype do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(String.length(@target_word))
    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    if length(chromosome.genes) != String.length(@target_word) do
      raise "genes changed length: #{chromosome.genes}}"
    end


    target = @target_word
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness == 1 || temperature < 20 || generation > 10000
  end
end

#Utilities.Benchmarker.run(Speller)
#Utilities.Profiler.run(Speller)


soln = Genetic.run(Speller,
  selection_type: &Toolbox.Selection.tournament(&1, &2, 3),
  selection_rate: 0.62,
  crossover_type: &Toolbox.Crossover.uniform(&1, &2),
  reinsertion_strategy: &Toolbox.Reinsertion.uniform(&1, &2, &3, 0.15),
  mutation_type: &Toolbox.Mutation.gaussian(&1, true),
  mutation_rate: 0.2
)

IO.write("\n")
IO.inspect(soln)

stats = :ets.tab2list(:statistics)
        |> Enum.map(fn {gen, stats} -> [gen, stats.mean_fitness] end)
{:ok, cmd} =
  Gnuplot.plot([
    [:set, :title, "mean fitness versus generation"],
    [:plot, "-", :with, :points]
  ], [stats])

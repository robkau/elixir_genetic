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
    target = @target_word
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], _generation, _temperature) do
    #temperature < 1
    best.fitness == 1
  end
end

soln = Genetic.run(Speller,
  selection_type: &Toolbox.Selection.roulette(&1, &2),
  crossover_type: &Toolbox.Crossover.uniform(&1, &2, 0.5),
  reinsertion_strategy: &Toolbox.Reinsertion.uniform(&1, &2, &3, 0.1),
  selection_rate: 0.75,
  mutation_rate: 0.1
)

IO.write("\n")
IO.inspect(soln)
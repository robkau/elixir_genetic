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
  def terminate?([best | _], _generation, _temperature) do
    #temperature < 1
    best.fitness == 1
  end
end

soln = Genetic.run(Speller,
  selection_type: &Toolbox.Selection.tournament(&1, &2, 10),
  selection_rate: 0.65,
  #crossover_type: &Toolbox.Crossover.uniform(&1, &2),
  reinsertion_strategy: &Toolbox.Reinsertion.elitist(&1, &2, &3, 0.05),
  mutation_type: &Toolbox.Mutation.gaussian(&1, true),
  mutation_rate: 0.3
)

IO.write("\n")
IO.inspect(soln)
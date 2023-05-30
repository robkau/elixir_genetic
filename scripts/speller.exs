defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  @target_word "supercalifragilisticexpialidocious"

  @impl true
  def genotype do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(String.length(@target_word))
    %Chromosome{genes: genes, size: String.length(@target_word)}
  end

  @impl true
  def fitness_function(chromosome) do
    target = @target_word
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    #temperature < 1
    best.fitness == String.length(@target_word)
  end
end

soln = Genetic.run(Speller, selection_strategy: &Toolbox.Selection.roulette/2)

IO.write("\n")
IO.inspect(soln)
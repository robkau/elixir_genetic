defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome
  use Bitwise

  @impl true
  def genotype do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end

  @impl true
  def fitness_function(chromosome) do
    target = 'ILoveGeneticAlgorithms'
    encrypted = 'LIjs`B`k`qlfDibjwlqmhv'

    cipher = fn word, key -> Enum.map(word, &rem(bxor(&1, key), 32768)) end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(List.to_string(target), guess)
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness == 1
  end
end

soln =
  Genetic.run(Codebreaker,
    crossover_type: &Toolbox.Crossover.uniform(&1, &2, 0.5),
    mutation_type: &Toolbox.Mutation.flip(&1, 0.5)
  )

IO.write("\n\nSolution found:\n")
IO.inspect(soln)

{key, ""} =
  soln.genes
  |> Enum.map(&Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)

IO.write("\n The key is #{key}\n")
use Bitwise
cipher = fn word, key -> Enum.map(word, &rem(bxor(&1, key), 32768)) end
IO.write("\nThe decrypted data is #{List.to_string(cipher.('LIjs`B`k`qlfDibjwlqmhv', key))}")

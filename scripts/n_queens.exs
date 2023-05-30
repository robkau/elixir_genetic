defmodule NQueens do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype do
    genes = Enum.shuffle(0..7)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_function(chromosome) do
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)
          dy =
            abs(
              chromosome.genes
              |> Enum.at(i)
              |> Kernel.-(Enum.at(chromosome.genes, j))
            )
          if dx == dy do
            1
          else
            0
          end
        else
          0
        end
      end
    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness == 8
  end
end

soln = Genetic.run(NQueens, selection_type: &Toolbox.Selection.tournament(&1, &2, 4), crossover_type: &Toolbox.Crossover.uniform(&1, &2, 0.5))

IO.write("\n\nSolution found:\n")
IO.inspect(soln)
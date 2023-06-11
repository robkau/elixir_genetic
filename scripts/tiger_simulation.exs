defmodule TigerSimulation do
  @behaviour Problem
  alias Types.Chromosome

  @num_generations 3

  # todo dot graph does not look like the book, generation 0 does not connect to generation 1.

  @impl true
  def genotype do
    genes = for _ <- 1..8, do: Enum.random(0..1)
    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    _tropic_scores = [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
    tundra_scores = [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]

    chromosome.genes
    |> Enum.zip(tundra_scores)
    |> Enum.map(fn {t, s} -> t * s end)
    |> Enum.sum()
  end

  @impl true
  def terminate?(_population, generation, _temperature), do: generation == @num_generations

  def average_tiger(population) do
    genes = Enum.map(population, & &1.genes)
    fitnesses = Enum.map(population, & &1.fitness)
    ages = Enum.map(population, & &1.age)
    num_tigers = length(population)

    avg_fitness = Enum.sum(fitnesses) / num_tigers
    avg_age = Enum.sum(ages) / num_tigers

    avg_genes =
      genes
      |> Enum.zip()
      |> Enum.map(&(Enum.sum(Tuple.to_list(&1)) / num_tigers))

   Chromosome.new(avg_genes, avg_fitness, avg_age)
  end
end

tiger =
  Genetic.run(TigerSimulation,
    population_size: 2,
    selection_rate: 0.9,
    mutation_rate: 0.1,
    statistics: [average_tiger: &TigerSimulation.average_tiger/1]
  )

IO.write("\n")
IO.inspect(tiger)

{_, zero_gen_stats} = Utilities.Statistics.lookup(0)
#{_, fivehundred_gen_stats} = Utilities.Statistics.lookup(500)
#{_, onethousand_gen_stats} = Utilities.Statistics.lookup(1000)

IO.inspect(zero_gen_stats)
#IO.inspect(fivehundred_gen_stats)
#IO.inspect(onethousand_gen_stats)

genealogy = Utilities.Genealogy.get_tree()

{:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)
{:ok, dotfile} = File.open('tiger_simulation.dot', [:write])
:ok = IO.binwrite(dotfile, dot)
:ok = File.close(dotfile)

#IO.inspect(Graph.vertices(genealogy))

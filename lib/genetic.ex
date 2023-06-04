defmodule Genetic do
  alias Types.Chromosome

  # Create population of initial chromosomes
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  # Sort by most fit
  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fn chromosome -> chromosome.fitness end, &>=/2)
  end

  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents =
      select_fn
      |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2])
        [c1, c2 | acc]
        # todo? [c1 | [c2 | acc]]
      end
    )

    # |> Enum.map(& repair_chromosome(&1))
  end

  def repair_chromosome(chromosome) do
    # todo: repair strategies
    genes = MapSet.new(chromosome.genes)
    new_genes = repair_helper(genes, chromosome.size)
    %Chromosome{chromosome | genes: new_genes}
  end

  defp repair_helper(chromosome, k) do
    if MapSet.size(chromosome) >= k do
      # todo drop extra genes off the end?
      MapSet.to_list(chromosome)
    else
      # fill in empty spot with new gene from normal distribution of current genes
      mu = Toolbox.Mutation.mu(chromosome)
      num = :rand.normal(mu, Toolbox.Mutation.sigma(chromosome, mu))
      repair_helper(MapSet.put(chromosome, num), k)
    end
  end

  def mutation(population, opts \\ []) do
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)

    n = floor(length(population) * rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(& apply(mutate_fn, [&1]))
  end

  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end

  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0, opts)

    population
    |> evolve(problem, 0, 0, 50, opts)
  end

  def evolve(population, problem, generation, last_max_fitness, temperature, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    best_fitness = best.fitness

    temperature = 0.999 * (temperature + (best_fitness - last_max_fitness))
    IO.write("\rCurrent Best: #{inspect(best)}")

    if problem.terminate?(population, generation, temperature) do
      IO.write("\n\nTerminated run.\n\n")
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)

      mutants = mutation(population, opts)
      offspring = children ++ mutants

      # de-chunk the parent pairs
      parents = parents
                  |> Enum.reduce([],
                       fn {p1, p2}, acc ->
                         [p1, p2 | acc]
                       end)

      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation+1, best_fitness, temperature, opts)
    end
  end
end

defmodule Genetic do
  alias Types.Chromosome

  # Create population of initial chromosomes
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    population = for _ <- 1..population_size, do: genotype.()
    Utilities.Genealogy.add_chromosomes(population)
    population
  end

  # Sort by most fit
  def evaluate(population, fitness_function, _opts \\ []) do
    population
    |> pmap(fn chromosome ->
      fitness = fitness_function.(chromosome)
      %Chromosome{chromosome | fitness: fitness, age: chromosome.age + 1}
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
      |> pmap(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2])
        Utilities.Genealogy.add_chromosome(p1, p2, c1)
        Utilities.Genealogy.add_chromosome(p1, p2, c2)
        [c1 | [c2 | acc]]
      end
    )

    #    population
    #    |> pmap(
    #      fn {p1, p2} ->
    #        {c1, c2} = apply(crossover_fn, [p1, p2])
    #        Utilities.Genealogy.add_chromosome(p1, p2, c1)
    #        Utilities.Genealogy.add_chromosome(p1, p2, c2)
    #        {c1, c2}
    #      end
    #    )

    # |> pmap(& repair_chromosome(&1))
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
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.shuffle/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)

    n = floor(length(population) * rate)

    population
    |> Enum.take_random(n)
    |> pmap(fn c ->
      mutant = apply(mutate_fn, [c])
      Utilities.Genealogy.add_chromosome(c, mutant)
      mutant
    end)
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
    statistics(population, generation, opts)
    best = hd(population)
    best_fitness = best.fitness

    temperature = 0.999 * (temperature + (best_fitness - last_max_fitness))

    if generation |> rem(100) == 0 do
      {_, current_generation_statistics} = Utilities.Statistics.lookup(generation)

      IO.write(
        "\r\nGeneration: #{generation}\nPopulation: #{current_generation_statistics.population_size}\nCurrent best genes: #{inspect(best.genes)}\nCurrent best score: :#{best_fitness}\n"
      )
    end

    if problem.terminate?(population, generation, temperature) do
      IO.write("\n\nTerminated run.\n\n")
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)

      mutants = mutation(population, opts)
      offspring = children ++ mutants

      # de-chunk the parent pairs
      parents =
        parents
        |> Enum.reduce(
          [],
          fn {p1, p2}, acc ->
            [p1, p2 | acc]
          end
        )

      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, best_fitness, temperature, opts)
    end
  end

  def statistics(population, generation, opts \\ []) do
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &(Enum.sum(Enum.map(&1, fn c -> c.fitness end)) / length(population)),
      population_size: fn _p -> length(population) end
    ]

    extra_stats = Keyword.get(opts, :statistics, [])

    stats_map =
      default_stats
      |> Keyword.merge(extra_stats)
      |> Enum.reduce(
        %{},
        fn {key, func}, acc ->
          Map.put(acc, key, func.(population))
        end
      )

    Utilities.Statistics.insert(generation, stats_map)
  end

  # Parallel helper
  # todo can look at replacing other Enum.map calls
  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await(&1))
  end
end

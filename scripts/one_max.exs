population = for _ <- 1..100, do: for(_ <- 1..1000, do: Enum.random(0..1))

# Sort chromosomes by performance
fitness = fn population ->
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

# Take pairs of best chromosomes
selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

# For each chromosome pair, cut both chromosomes in half at random point
# And then swap the tail parts
crossover = fn population ->
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(1000)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

# Each chromosome has a 5% chance to shuffle all genes
mutation = fn population ->
  population
  |> Enum.map(fn chromosome ->
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end

algorithm = fn population, algorithm ->
  best = Enum.max_by(population, &Enum.sum/1)
  IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

  if Enum.sum(best) == 1000 do
    best
  else
    # Initial population
    population
    # Evaluate
    |> fitness.()
    # Select parents
    |> selection.()
    # Create children
    |> crossover.()
    # Random mutations
    |> mutation.()
    # Repeat with new population
    |> algorithm.(algorithm)
  end
end

solution = algorithm.(population, algorithm)
IO.write("\n Answer is \n")
IO.inspect(solution)

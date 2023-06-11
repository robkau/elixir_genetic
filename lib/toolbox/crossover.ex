defmodule Toolbox.Crossover do
  alias Types.Chromosome

  # Randomly selects a split point and then cuts/rejoins the chromosomes at that point
  # No regard for validity of new chromosome
  def single_point(p1, p2) do
    cut_point = :rand.uniform(length(p1.genes))
    {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cut_point), Enum.split(p2.genes, cut_point)}
    c1 = h1 ++ t2
    c2 = h2 ++ t1
    {Chromosome.new(c1, p1.fitness, p1.age),
    Chromosome.new(c2, p2.fitness, p2.age)}
  end

  def single_point_multi_parents([]) do
    raise "You must use at least one parent"
  end

  def single_point_multi_parents([p1 | []]), do: p1

  def single_point_multi_parents(parents) do
    crossover_point = :rand.uniform(hd(parents).size)

    parents
    |> Enum.chunk_every(2, 1, [hd(parents)])
    |> Enum.map(&List.to_tuple(&1))
    |> Enum.reduce(
      [],
      fn {p1, p2}, chd ->
        {front, _} = Enum.split(p1.genes, crossover_point)
        {_, back} = Enum.split(p2.genes, crossover_point)
        c = front ++ back
        p = Chromosome.new(c, p1.fitness, p1.age)
        [p | chd]
      end
    )
  end

  # Randomly swaps matching pairs of genes between parents
  # May be good strategy for binary genotypes
  # May be slow for large chromosomes
  def uniform(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {Chromosome.new(c1, p1.fitness, p1.age),
      Chromosome.new(c2, p2.fitness, p2.age)}
  end

  # Davis order crossover
  # Takes a random piece of p1 as parent, then fills rest from p2
  # May be used for permutations or ordered lists
  # Tries to preserve integrity of the permutation (avoid duplicate/missing elements after crossover)
  # May be slow for large chromosomes
  def order_one(p1, p2) do
    lim = Enum.count(p1.genes) - 1

    # Get random range
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # make and return
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {Chromosome.new(c1, p1.fitness, p1.age),
      Chromosome.new(c2, p2.fitness, p2.age)}
  end

  # Strategy for real-valued chromosomes
  # Uses arithmetic to randomly set new value somewhere inbetween parent values
  # No randomless involved so may converge too quickly (to fix: only combine a certain percent of genes)
  def whole_arithmetic(p1, p2, alpha) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        {
          x * alpha + y * (1 - alpha),
          x * (1 - alpha) + y * alpha
        }
      end)
      |> Enum.unzip()

    {Chromosome.new(c1, p1.fitness, p1.age),
      Chromosome.new(c2, p2.fitness, p2.age)}
  end
end

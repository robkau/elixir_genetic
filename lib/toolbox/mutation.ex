defmodule Toolbox.Mutation do
  alias Types.Chromosome
  import Bitwise

  # Defines mutation strategies
  # Mutations may change the length of chromosome.genes
  # Mutations must not change the value of chromosome.size to match (chromosome repair expects the original value)

  # Flip a certain percentage of genes from 1 to 0, and vice versa
  # Only works on binary genotype
  def flip(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn g ->
        if :rand.uniform() < p do
          #bxor(g, 1) ?
          g ^^^ 1
        else
          g
        end
      end)

    Chromosome.new(genes, chromosome.fitness, chromosome.age)
  end

  # Shuffle all genes
  def shuffle(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    Chromosome.new(genes, chromosome.fitness, chromosome.age)
  end

  # Shuffle genes in a random slice of length n
  def shuffle(chromosome, n)
    when length(chromosome.genes) < 2
    when length(chromosome.genes) < n
    when n < 2 do
      Chromosome.new(chromosome.genes, chromosome.fitness, chromosome.age+1)
  end
  def shuffle(chromosome, n) do
    start = :rand.uniform(n - 1)
    over = Kernel.min(0, start + n - chromosome.size)
    {lo, hi} =
      if over < 1 do
        {start, start + n}
      else
        {start - over, start + n}
      end

    head = Enum.slice(chromosome.genes, 0, lo)
    mid = Enum.slice(chromosome.genes, lo, hi - lo)
    tail = Enum.slice(chromosome.genes, hi, chromosome.size)


    genes = head ++ Enum.shuffle(mid) ++ tail
    Chromosome.new(genes, chromosome.fitness, chromosome.age)
  end





  # Increment/Decrement genes by gaussian random number distribution
  # (calculate mean and standard deviation and use that for all new random numbers)
  # Tends to mutate a gene slowly, keeping close to original value
  # Works for real-valued genes
  def gaussian(chromosome) do gaussian(chromosome, false) end
  def gaussian(chromosome, truncate) when length(chromosome.genes) < 1 do Chromosome.new(chromosome.genes, chromosome.fitness, chromosome.age) end
  def gaussian(chromosome, truncate) when not is_boolean(truncate) do raise "truncate must be a boolean" end
  def gaussian(chromosome, truncate) do
    mu = chromosome |> mu
    genes =
      chromosome.genes
      |> Enum.map(fn _ ->
        :rand.normal(mu, chromosome |> sigma(mu))
      end)
      |> Enum.map(fn v ->
        if !truncate do
          v
          else
          floor(v)
        end
      end)

    Chromosome.new(genes, chromosome.fitness, chromosome.age)
  end

  def mu(chromosome) do
    Enum.sum(chromosome.genes) / chromosome.size
  end

  def sigma(chromosome, mu) do
    chromosome.genes
    |> Enum.map(fn x -> (mu - x) * (mu - x) end)
    |> Enum.sum()
    |> Kernel./(chromosome.size)
  end

  # todo p.122 further ideas
  # - uniform
  # - invert
end

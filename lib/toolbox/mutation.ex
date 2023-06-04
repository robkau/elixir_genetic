defmodule Toolbox.Mutation do
  alias Types.Chromosome
  use Bitwise

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
          g ^^^ 1
        else
          g
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end

  # Scramble all genes
  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{chromosome | genes: genes}
  end

  # Scramble genes in a random slice of length n
  def scramble(chromosome, n) do
    start = :rand.uniform(n - 1)

    {lo, hi} =
      if start + n >= chromosome.size do
        {start - n, start}
      else
        {start, start + n}
      end

    head = Enum.slice(chromosome.genes, 0, lo)
    mid = Enum.slice(chromosome.genes, lo, hi)
    tail = Enum.slice(chromosome.genes, hi, chromosome.size)

    %Chromosome{chromosome | genes: head ++ Enum.shuffle(mid) ++ tail}
  end

  # Scramble genes by gaussian random number distribution
  # (calculate mean and standard deviation and use that for all new random numbers)
  # Tends to mutate a gene slowly, keeping close to original value
  # Works for real-valued genes
  def gaussian(chromosome) do
    mu = chromosome|>mu
    genes =
      chromosome.genes
      |> Enum.map(fn _ ->
        :rand.normal(mu, chromosome|>sigma(mu))
      end)

    %Chromosome{chromosome | genes: genes}
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
  # - swap
  # - uniform
  # - invert
end

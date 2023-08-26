defmodule CrossoverTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Types.Chromosome

  # todo list of functions to run identical tests for

  property "single_point/2 maintains the size of input chromosomes" do
    check all size <- integer(0..100),
          gene_1 <- list_of(integer(), length: size),
          gene_2 <- list_of(integer(), length: size) do
      p1 = Chromosome.new(gene_1, 1, 1)
      p2 = Chromosome.new(gene_2, 1, 1)
      {c1, c2} = Toolbox.Crossover.single_point(p1, p2)
      assert c1.size == size
      assert c2.size == size
    end
  end

  property "order_one/2 maintains the size of input chromosomes" do
    check all size <- integer(0..100),
          gene_1 <- list_of(integer(), length: size),
          gene_2 <- list_of(integer(), length: size) do
      p1 = Chromosome.new(gene_1, 1, 1)
      p2 = Chromosome.new(gene_2, 1, 1)
      {c1, c2} = Toolbox.Crossover.order_one(p1, p2)
      assert c1.size == size
      assert c2.size == size
    end
  end
end
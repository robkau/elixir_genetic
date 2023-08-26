defmodule MutationTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Types.Chromosome

  property "scramble/2 maintains the size of input chromosomes" do
    check all size <- integer(0..100),
          gene <- list_of(integer(), length: size),
          n <- integer(0..size) do
      p = Chromosome.new(gene, 1, 1)
      p2 = Toolbox.Mutation.shuffle(p, n)
      assert p.size == size
      assert p2.size == size
    end
  end
end
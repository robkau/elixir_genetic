defmodule NifRngTest do
  use ExUnit.Case
  use ExUnitProperties


  property "int_range(0) is 1" do
      assert Genetic.Rng.int_range(0) == 1
  end

  property "int_range/1 constrained from 1 to max" do
    check all max <- integer(0..100) do
      v = Genetic.Rng.int_range(max)

      assert v >= 1
      assert v <= max
    end
  end

  property "int_range/1 from 1 <= N <= max" do
    tries = 50
    max = 2

    assert was_seen(-1, max, tries) == false
    assert was_seen(0, max, tries) == false
    assert was_seen(1, max, tries) == true
    assert was_seen(2, max, tries) == true
    assert was_seen(3, max, tries) == false
    assert was_seen(4, max, tries) == false
  end

  property "float/0 returns between 0 and 1" do
    (0..100)
      |> Enum.map(fn _ ->
        v = Genetic.Rng.float()
        assert v >= 0
        assert v < 1
    end)
  end

  defp was_seen(val, max, tries) do
         (1..tries)
         |> Enum.map(fn _ ->
           Genetic.Rng.int_range(max) == val
         end)
         |> Enum.member?(true)
   end
end
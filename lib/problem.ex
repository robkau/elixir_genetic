# To solve a problem using the genetic module, supply:
# - a genotype (function to generate new chromosomes)
# - a fitness function (to evaluate a given chromosome)
# - an end point
defmodule Problem do
  alias Types.Chromosome
  @callback genotype :: Chromosome.t()
  @callback fitness_function(Chromosome.t()) :: number()
  @callback terminate?(Enum.t(), integer(), integer()) :: boolean()
end

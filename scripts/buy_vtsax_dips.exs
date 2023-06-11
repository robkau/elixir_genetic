defmodule BuyVtsaxDips do
  @behaviour Problem
  alias Types.Chromosome

  # Assumptions:
  # - CSV files with daily stock price and dividend history
  # - 250 dollars invested on the 1st and 15th of every month
  # - Time period from 2000 to 2023


  # Fitness calculated as:
  # Percent return per year from 2000-2023 (buying dips with this strategy)
  # MINUS
  # Percent return per year from 2000-2023 (buy and hold)
  @target_fitness 10

  @impl true
  def genotype do
    genes =
      for _ <- 1..10,
          do: {
            # base
            :rand.uniform(10),
            # power
            :rand.uniform(10)
          }
    # Todo: exponential equation for probability/amount of buying compared to price change
    # Todo: weight overnight, 7DMA, 60DMA, 365DMA
    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    return 0
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness > @target_fitness
  end
end

soln = Genetic.run(BuyVtsaxDips, population_size: 50)

IO.write("\n")
IO.inspect(soln)

defmodule BuyVtsaxDips do
  @behaviour Problem
  alias Types.Chromosome

  # Assumptions:
  # - CSV files with daily stock price and dividend history
  # - 250 dollars invested on the 1st and 15th of every month
  # - Time period from 2000 to 2023

  @daily_prices "./data/vtsax-daily-price.csv"
  @daily_dividends "./data/vtsax-dividends.csv"

  # todo memoize
  defp rows do
    @daily_prices
    |> Path.expand(__DIR__)
    |> File.stream!()
    # ["date", "open", "high", "low", "close", "adj_close", "volume"]
    |> CSV.decode!(headers: true)
  end

  defp price_per_day do
    rows()
    |> Enum.map(fn keys ->
      keys["High"]
      |> String.to_float()
    end)
  end

  # Fitness calculated as:
  # Percent return per year from 2000-2023 (buying dips with this strategy)
  # MINUS
  # Percent return per year from 2000-2023 (buy and hold)
  @target_fitness 4
  @buy_and_hold_chromosome [[{1, 0}, {0, 0}]]
  @starting 0.0
  @per_day 10

  def roi(genes, starting, per_day) do
    price_per_day()
    |> Enum.reduce({starting, 0.0, 0.0}, fn price, acc ->
      money = elem(acc, 0)
      money = money + per_day
      shares = elem(acc, 1)

      last_price =
        if elem(acc, 2) != 0 do
          elem(acc, 2)
        else
          price
        end

      IO.write("\n\nPrice: #{price}")
      IO.write("\nLast price: #{last_price}")

      percent_change = 100.0 * (price - last_price) / last_price

      IO.write("\nMoney: #{money}")

      if shares > 0 do
        IO.write("\nShares: #{shares}")
      end

      IO.write("\nPercent change: #{percent_change}")

      amount_to_spend =
        if percent_change > 0 do
          0.0
        else
          eligible_buys =
            genes
            |> Enum.map(fn x ->
              Enum.at(x,1)
            end)
            |> Enum.filter(fn x ->
              percent_change * -10 > elem(x, 1)
            end)
            |> Enum.reverse()

          cond do
            length(eligible_buys) < 1 ->
              0.0

            true ->
              [{amount, threshold} | _] = eligible_buys
              if amount <= 0 do
                0.0
              end
              Kernel.max(0, floor(Kernel.min(money, amount * money)))
          end
        end

      shares_to_sell =
        if percent_change < 0 || shares < 0 do
          0.0
        else
          eligible_sells =
            genes
            |> Enum.map(fn x ->
              Enum.at(x, 1)
            end)
            |> Enum.filter(fn x ->
              percent_change * 10 > elem(x, 1)
            end)
            |> Enum.reverse()

          cond do
            length(eligible_sells) < 1 ->
              0.0
            true ->
              [{amount, threshold} | _] = eligible_sells
              if amount <= 0 do
                0.0
              end

              Kernel.max(0, floor(Kernel.min(shares, shares * amount)))
          end
        end

      shares_bought =
        if amount_to_spend <= 0 do
          0.0
        else
          IO.write("\n***spending #{inspect(amount_to_spend)}")
          amount_to_spend / price
        end

      sell_value =
        if shares_to_sell > 0 do
          IO.write("\n***selling #{shares_to_sell} shares")
          shares_to_sell * price
        else
          0.0
        end

      {money - amount_to_spend + sell_value, shares - shares_to_sell + shares_bought, price}
    end)
  end

  @impl true
  def genotype do
    genes =
      for i <- 0..9,
          do: [{
            # amount to buy if threshold is met
            i * 0.105 + 0.055,
            # threshold to buy on last price change
            :rand.uniform(1000)
          },
            {
              # amount to sell if threshold is met
              i * 0.105 + 0.055,
              # threshold to sell on last price change
              :rand.uniform(1000)
            }
          ]

    Chromosome.new(genes)
  end

  @impl true
  def fitness_function(chromosome) do
    {end_money, end_shares, end_share_price} = roi(chromosome.genes, @starting, @per_day)

    {baseline_money, baseline_shares, baseline_share_price} =
      roi(@buy_and_hold_chromosome, @starting, @per_day)

    end_value = end_money + end_shares * end_share_price
    baseline_value = baseline_money + baseline_shares * baseline_share_price
    percent_change_in_value_compared_to_baseline = ((end_value - baseline_value  )/baseline_value) * 100

    IO.write("\nend")
    IO.inspect({end_value, end_money, end_shares, percent_change_in_value_compared_to_baseline})
    IO.write("\nbaseline:")
    IO.inspect({baseline_value, baseline_money, baseline_shares })
    percent_change_in_value_compared_to_baseline
  end

  @impl true
  def terminate?([best | _], generation, temperature) do
    best.fitness > @target_fitness || generation > 500
  end
end

soln = Genetic.run(BuyVtsaxDips, population_size: 2)

IO.write("\n")
IO.inspect(soln)

defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Genetic.Application, []}
    ]
  end

  defp deps do
    [
      {:alex, "~> 0.3.2"},
      {:gnuplot, "~> 1.19"},
      {:libgraph, "~> 0.13"}
    ]
  end
end

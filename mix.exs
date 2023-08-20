defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Not working in windows! compilers: [:genetic] ++ Mix.compilers,
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
      #{:alex, "~> 0.3.2"},  enabling this makes compiling more difficult
      {:benchee, "~> 1.0.1"},
      {:csv, "~> 3.0"} ,
      {:exprof, "~> 0.2.0"},
      {:gnuplot, "~> 1.19"},
      {:libgraph, "~> 0.13"},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end
end

# Not working in windows!
#defmodule Mix.Tasks.Compile.Genetic do
#  use Mix.Task.Compiler
#
#  def run(_args) do
#    {result, _errcode} =
#      System.cmd(
#      "mingw64/bin/gcc",
#      ["-fpic", "-shared", "-Isrc", "-o", "genetic.so", "src/genetic.c"],
#      stderr_to_stdout: true
#      )
#      IO.puts(result)
#  end
#end

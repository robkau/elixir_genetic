defmodule Utilities.Profiler do
  import ExProf.Macro

  def do_analyze problem do
    profile do
      Genetic.run(problem)
      Genetic.run(problem,
        selection_type: &Toolbox.Selection.tournament_no_duplicates(&1, &2, 3),
        selection_rate: 0.65,
        crossover_type: &Toolbox.Crossover.uniform(&1, &2),
        reinsertion_strategy: &Toolbox.Reinsertion.elitist(&1, &2, &3, 0.05),
        mutation_type: &Toolbox.Mutation.shuffle(&1),
        mutation_rate: 0.3
      )

    end
  end

  def run problem do
    {records, _block_result} = do_analyze problem
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect("total = #{total_percent}")
  end
end
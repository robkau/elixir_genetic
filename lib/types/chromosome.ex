

defmodule Types.Chromosome do
  use Agent

  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys [:genes, :id, :size, :fitness, :age]
  defstruct [:genes, id: "default", size: 0, fitness: 0, age: 0]

  def new(genes) do
    %Types.Chromosome{genes: genes, id: Base.encode16(:crypto.strong_rand_bytes(64)), size: length(genes), age: 0, fitness: 0}
  end

  def new(genes, fitness, age) do
    %Types.Chromosome{genes: genes, id: Base.encode16(:crypto.strong_rand_bytes(64)), size: length(genes), age: age, fitness: fitness}
  end


  # Agent implementation to replace Task.async calls.
  # To enable, genetic.ex would need to use this in initialize+evaluate (p.182)
  def start_link(genes) do
    Agent.start_link(fn -> new(genes) end)
  end
  def get_fitness(pid) do
    Agent.get(pid, & &1.fitness)
  end
  def eval(pid, fitness) do
    c = Agent.get(pid, & &1)
    Agent.update(pid, fn -> new(c.genes, fitness.(c), c.age + 1) end)
  end
end

defmodule Types.Chromosome do
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
end

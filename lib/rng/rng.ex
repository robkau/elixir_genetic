defmodule Genetic.Rng do
  use Rustler, otp_app: :genetic, crate: "rng"

  # When your NIF is loaded, it will override this function.
  def int(), do: :erlang.nif_error(:nif_not_loaded)
  def int_range(a), do: :erlang.nif_error(:nif_not_loaded)
  def float(), do: :erlang.nif_error(:nif_not_loaded)
end
